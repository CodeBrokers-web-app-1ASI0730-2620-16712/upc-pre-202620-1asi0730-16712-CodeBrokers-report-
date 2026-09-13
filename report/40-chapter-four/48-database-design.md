## 4.8. Database Design

El diseño de la base de datos traduce el modelo de dominio de la sección 4.7 a un esquema relacional sobre **PostgreSQL 16**, manteniendo la separación por bounded contexts establecida en la sección 4.6. La correspondencia no es únicamente conceptual: **cada bounded context recibe su propio schema de PostgreSQL** —`iam`, `elder_care`, `monitoring`, `alerting`, `care_coordination`, `notification` y `marketing`—, de modo que la frontera lógica del Domain-Driven Design queda materializada físicamente y cada contexto resulta dueño exclusivo de sus tablas. El esquema completo está versionado en el repositorio como `diagrams/database/schema.sql`.

### Reglas de mapeo del modelo de dominio

El mapeo del modelo de clases al esquema relacional sigue reglas consistentes en los siete contextos:

| Concepto del modelo de dominio | Representación en la base de datos |
| :--- | :--- |
| **Aggregate Root** | Tabla principal con llave primaria propia |
| **Entidad interna** | Tabla hija con llave foránea hacia la raíz y borrado en cascada |
| **Value Object** | Columnas embebidas con prefijo, nunca una tabla independiente |
| **Referencia entre agregados** | Columna de llave foránea, sin navegación de objetos |
| **Enumeración** | `VARCHAR` con restricción `CHECK`, nunca valores ordinales |
| **Especificación del dominio** | Restricción `CHECK` cuando la regla es expresable en SQL |
| **Marca de tiempo** | `TIMESTAMPTZ`, para preservar la zona horaria |

Las llaves primarias son de tipo **`UUID`**, en correspondencia con los Value Objects de identidad definidos en los diagramas de clases. Esta decisión permite generar el identificador antes de persistir el agregado, lo que simplifica la publicación de eventos de dominio dentro de la misma transacción, y evita exponer en las URL el volumen de pacientes y alertas que maneja la plataforma.

Los Value Objects se almacenan como columnas embebidas con un prefijo que identifica al objeto de origen. El Value Object `Address` se persiste como `address_street`, `address_district` y `address_city`; `EmergencyContact` como `emergency_contact_name` y `emergency_contact_phone`; `Observation` como `observation_text` y `observation_written_at`. De esta manera se conserva la trazabilidad hacia el modelo de clases sin generar tablas adicionales para objetos que carecen de identidad propia, y sin comprometer la atomicidad exigida por la primera forma normal.

Las llaves foráneas se declaran también entre schemas distintos. Esto es posible porque la solución se despliega como un modular monolith sobre una única base de datos, según el Container Diagram de la sección 4.6.3, y permite que la integridad referencial entre contextos la garantice el motor y no la capa de aplicación. Si en el futuro un bounded context se extrajera a su propia base de datos, estas llaves se convertirían en referencias lógicas validadas por la aplicación, sin que el modelo de dominio cambie.

### Análisis de formas normales

El esquema cumple hasta la **forma normal de Boyce-Codd (BCNF)**. El análisis se detalla a continuación.

**Primera forma normal (1FN).** Todas las columnas contienen valores atómicos y no existen grupos repetitivos. Los dos casos que podían comprometerla se resolvieron extrayendo tablas propias: la lista de cuidadores de un adulto mayor vive en `elder_care.caregiver_assignments` y no como arreglo en `older_adults`, y el historial de estados de una alerta vive en `alerting.alert_status_changes` y no como texto acumulado en `alerts`. En el contexto Notification, una alerta de gravedad alta genera **dos filas** en `notifications` —una por canal— en lugar de una fila con una lista de canales.

**Segunda forma normal (2FN).** Al ser todas las llaves primarias simples —una única columna `UUID` o, en el catálogo de tipos, un `VARCHAR` código— no existen dependencias parciales posibles. No obstante, las claves candidatas naturales sí se protegen explícitamente: `UNIQUE (email)` en `iam.users`, `UNIQUE (user_id)` en los tres perfiles de `elder_care`, `UNIQUE (health_record_id)` en `alerting.alerts` y un **índice único parcial** sobre `(older_adult_id, family_caregiver_id) WHERE revoked_at IS NULL`, que impide dos asignaciones vigentes del mismo cuidador sobre el mismo adulto mayor sin bloquear el registro histórico de asignaciones ya revocadas.

**Tercera forma normal (3FN).** El diseño inicial presentaba tres dependencias transitivas que fueron eliminadas:

1. **`care_records.older_adult_id`.** El adulto mayor quedaba determinado por `alert_id`, que a su vez lo determinaba. La columna se eliminó y el dato se obtiene uniendo con `alerting.alerts`, lo que además elimina la posibilidad de que ambos valores se desincronicen.
2. **`family_caregivers.email` y `care_providers.email`.** El correo quedaba determinado por `user_id` y ya existía en `iam.users`. Las columnas se eliminaron: el correo de contacto de un usuario es el de su cuenta, y duplicarlo habría permitido notificar a una dirección desactualizada.
3. **La unidad de medida de un registro de salud.** La unidad depende del tipo de registro —`HEART_RATE` se mide en bpm, `GLUCOSE` en mg/dL—, no del registro individual, de modo que almacenarla en `health_records` habría creado la dependencia transitiva `id → record_type_code → unit`. Por esta razón `RecordType` es la **única enumeración del modelo que se promovió a tabla de catálogo** (`monitoring.record_types`) en lugar de resolverse con una restricción `CHECK`: a diferencia de las demás, no es un enumerado puro sino un concepto con atributos propios.

**Forma normal de Boyce-Codd (BCNF).** Se verificó que todo determinante de cada relación sea una clave candidata. El único caso que requería revisión es `iam.users`, donde `email` determina al resto de atributos; como `email` está declarado `UNIQUE`, es clave candidata y la relación permanece en BCNF. En `monitoring.record_types`, `code` es a la vez llave primaria y única clave candidata.

**Denormalización deliberada.** Existe una sola excepción consciente, documentada en el diagrama de Alerting: las columnas `status` y `last_status_change_at` de `alerting.alerts` son derivables de la última fila de `alert_status_changes`. Se conservan en la raíz porque la US-08 exige mostrar el conteo de alertas pendientes al cargar la pantalla de inicio, y resolverlo por agregación sobre el historial en cada carga sería innecesariamente costoso sobre la consulta más frecuente del sistema. La consistencia queda garantizada por el propio agregado `Alert`, que es el único punto del código que escribe ambas tablas y siempre lo hace dentro de la misma transacción.

**Datos derivados que no se almacenan.** La edad del adulto mayor se calcula a partir de `birth_date` y nunca se persiste, ya que almacenarla generaría un valor que se vuelve incorrecto con el paso del tiempo sin que ninguna operación lo modifique.

### Restricciones que protegen reglas de negocio

Las restricciones no se limitan a llaves primarias y foráneas. El esquema incorpora restricciones `CHECK` que materializan criterios de aceptación directamente en el motor, de modo que una falla en la capa de aplicación no pueda producir datos inconsistentes:

* El seguimiento de un adulto mayor **no puede activarse con el perfil incompleto**: `is_monitoring_active = FALSE OR (dirección y contacto de emergencia IS NOT NULL)`. Esta restricción es la traducción literal de la US-21, y es la razón por la que esas columnas admiten `NULL` mientras el perfil está en construcción.
* Un registro de salud **origina como máximo una alerta**, mediante `UNIQUE (health_record_id)` en `alerts` (US-15).
* Ninguna transición de estado puede registrar el mismo estado de origen y destino: `from_status <> to_status` (US-19).
* La observación de una atención es opcional, pero **texto y fecha van juntos o no van**: `(observation_text IS NULL) = (observation_written_at IS NULL)` (US-13).
* Una notificación marcada como `SENT` obliga a tener fecha de envío e identificador del proveedor; una marcada como `FAILED` obliga a tener motivo de fallo.
* La especialidad de un lead **solo puede declararse cuando el visitante proviene del formulario de profesional de salud**: `segment = 'CARE_PROVIDER' OR specialty IS NULL` (US-03).
* Una regla de monitoreo exige al menos un límite y que los límites sean consistentes entre sí.

El esquema fue ejecutado sobre una instancia real de PostgreSQL 16 para validar su corrección: las trece tablas se crean sin errores y cada una de las restricciones anteriores rechaza efectivamente los intentos de violación, incluyendo el borrado en cascada de registros de salud, reglas y alertas al eliminar un adulto mayor.

### 4.8.1. Database Diagrams

#### Bounded Context: Identity and Access Management

El schema `iam` contiene una única tabla, `users`, que concentra las credenciales y el rol de acceso. No almacena ningún dato de perfil: nombres, teléfonos y direcciones pertenecen al contexto Elder Care, lo que evita duplicar información personal en dos lugares y mantiene el contexto de identidad reducido a su responsabilidad.

\includegraphics[width=\linewidth]{assets/481-db-01-iam.png}

#### Bounded Context: Elder Care

El schema `elder_care` agrupa los tres perfiles y la tabla de asignaciones. Cada perfil se vincula a su cuenta mediante `UNIQUE (user_id)`, lo que impone una relación uno a uno con `iam.users`. La vinculación con el proveedor de salud se resuelve con una sola columna, `assigned_provider_id`, de manera que la restricción de un único proveedor activo por adulto mayor (US-20) es estructural y no depende de la aplicación. Las políticas de borrado son deliberadamente distintas: eliminar un adulto mayor arrastra sus asignaciones (`CASCADE`), pero eliminar un cuidador o un proveedor con asignaciones o atenciones registradas está bloqueado (`RESTRICT`), porque hacerlo destruiría trazabilidad clínica.

\includegraphics[width=\linewidth]{assets/481-db-02-elder-care.png}

#### Bounded Context: Preventive Monitoring

El schema `monitoring` contiene el catálogo `record_types`, los registros de salud y las reglas de monitoreo. Los dos índices compuestos sobre `health_records` sostienen las consultas del historial: el primero, ordenado por `recorded_at DESC`, resuelve el orden cronológico descendente exigido por la US-11; el segundo añade el tipo de elemento para el filtrado por rango de fechas y tipo de la US-17. El índice único parcial sobre las reglas activas impide configurar dos reglas equivalentes vigentes para el mismo adulto mayor y tipo de registro.

\includegraphics[width=\linewidth]{assets/481-db-03-preventive-monitoring.png}

#### Bounded Context: Alerting

El schema `alerting` contiene la alerta y su historial de estados. El índice `(assigned_provider_id, status, severity)` cubre simultáneamente las dos consultas que alimentan la pantalla de inicio del médico: el conteo de alertas pendientes (US-08) y el listado ordenado por nivel de urgencia (US-09). El historial en `alert_status_changes` es lo que hace posible responder quién atendió una alerta y cuándo (US-18) sin recurrir a auditoría externa, y garantiza que ninguna transición destruya información previa (US-19).

\includegraphics[width=\linewidth]{assets/481-db-04-alerting.png}

#### Bounded Context: Care Coordination

El schema `care_coordination` contiene una única tabla. Admite varias filas por alerta, lo que permite que más de un profesional intervenga sobre el mismo caso y que el frontend distinga una alerta ya revisada de una sin revisar indicando quién la atendió (US-14). La restricción `UNIQUE (alert_id, attended_by, attended_at)` evita el registro duplicado de una misma intervención.

\includegraphics[width=\linewidth]{assets/481-db-05-care-coordination.png}

#### Bounded Context: Notification

El schema `notification` almacena una fila por mensaje individual, con su canal, su estado de entrega y su contador de reintentos. El índice parcial sobre `(status, attempts) WHERE status = 'FAILED'` sostiene el proceso de reintento sin recorrer el histórico completo de notificaciones ya entregadas. La columna `provider_message_id` es el único rastro del proveedor externo y se almacena como texto opaco, en coherencia con la capa Anti-Corruption Layer descrita en la sección 4.6.2.

\includegraphics[width=\linewidth]{assets/481-db-06-notification.png}

#### Bounded Context: Marketing

El schema `marketing` es el único que no mantiene ninguna llave foránea hacia el resto del modelo. Esto es intencional: un lead es un visitante anónimo que todavía no tiene cuenta, por lo que su correo es un dato propio de este contexto y no una referencia a `iam.users`. El aislamiento permite que el contexto comercial evolucione o se migre a una herramienta externa sin afectar al dominio clínico.

\includegraphics[width=\linewidth]{assets/481-db-07-marketing.png}
