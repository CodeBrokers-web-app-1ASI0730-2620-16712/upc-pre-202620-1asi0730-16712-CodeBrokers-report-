## 4.7. Software Object-Oriented Design

En esta sección se presenta el detalle de implementación de cada bounded context mediante diagramas de clases UML. Siguiendo los principios de Domain-Driven Design, cada diagrama identifica su Aggregate Root, las entidades internas que viven bajo esa raíz, los Value Objects que encapsulan conceptos sin identidad propia, las enumeraciones que representan los estados del dominio, los eventos de dominio que el agregado publica y las interfaces de repositorio y de puerto que definen los contratos de persistencia e integración.

La nomenclatura se alinea al Ubiquitous Language definido en la sección 2.5 y a las convenciones de C#, lenguaje del Backend REST API: los tipos se declaran en PascalCase, los campos privados en camelCase, los miembros públicos en PascalCase y las enumeraciones en mayúsculas con separación por guion bajo. Los métodos asíncronos de repositorio devuelven `Task<T>` y se sufijan con `Async`, según la convención de .NET.

Los diagramas aplican de manera consistente las siguientes reglas de modelado:

* **Referencia entre agregados exclusivamente por identidad.** Ningún agregado mantiene una referencia de objeto hacia otro agregado: una `Alert` conoce el `OlderAdultId` al que concierne, pero no navega hacia el objeto `OlderAdult`. Estas referencias cruzadas se representan en cada diagrama dentro del paquete *Referencias externas (por identidad)*, de modo que la frontera del bounded context resulte visible.
* **Identificadores como Value Objects tipados sobre `Guid`.** Esto impide confundir un `AlertId` con un `CareRecordId` en tiempo de compilación, y permite generar el identificador antes de persistir el agregado.
* **Métodos de negocio expresivos en lugar de setters.** Las invariantes se protegen dentro del propio agregado mediante métodos privados de validación (`EnsureNotDeactivated`, `ValidateTransition`, `EnsureBoundsAreConsistent`).
* **Entidades internas con constructor de visibilidad package-private (`~`).** Garantiza que `CaregiverAssignment` y `AlertStatusChange` solo puedan crearse a través de su raíz de agregado, preservando la trazabilidad.
* **Shared Kernel mínimo.** La única enumeración compartida entre contextos es `SeverityLevel`, utilizada por Preventive Monitoring para calificar la regla, por Alerting para priorizar la alerta y por Notification para seleccionar el canal de entrega.

### 4.7.1. Class Diagrams

#### Bounded Context: Identity and Access Management

El contexto de identidad protege un único agregado, `User`, que encapsula las credenciales y el ciclo de vida de la cuenta. El hash de la contraseña se modela como Value Object y el algoritmo de cifrado se delega en el puerto `IPasswordHasher`, de modo que el dominio no conoce la implementación criptográfica. La enumeración `UserRole` distingue los tres roles del sistema y es la que habilita el flujo de registro diferenciado para proveedores de salud (US-06).

\includegraphics[width=\linewidth]{assets/471-class-01-iam.png}

#### Bounded Context: Elder Care

Este contexto administra tres agregados independientes —`OlderAdult`, `CareProvider` y `FamilyCaregiver`— vinculados a Identity and Access Management únicamente por el `UserId`. El agregado `OlderAdult` es la raíz del seguimiento: mantiene la entidad interna `CaregiverAssignment`, que registra el parentesco y la autorización ante emergencias de cada familiar, y controla la vinculación con un único proveedor de salud activo a la vez mediante `LinkCareProvider` y la validación privada `EnsureNoActiveProvider` (US-20). La activación del seguimiento no es un simple cambio de bandera: `ActivateMonitoring` recibe la especificación `MandatoryProfileDataPolicy`, que además de aprobar o rechazar devuelve la lista de campos faltantes, satisfaciendo el criterio de aceptación que exige indicar qué información falta cuando la validación no se cumple (US-21).

\includegraphics[width=\linewidth]{assets/471-class-02-elder-care.png}

#### Bounded Context: Preventive Monitoring

El agregado `HealthRecord` representa cada registro de información de salud capturado sobre el adulto mayor, tipificado mediante `RecordType` y cuantificado mediante el Value Object `Measurement`. El agregado `MonitoringRule` encapsula las reglas configuradas: su Value Object `Threshold` define los límites admisibles y el método `Matches` determina si un registro los excede. El Domain Service `RiskEvaluationService` orquesta la evaluación, selecciona la regla de mayor severidad cuando varias coinciden y publica `RiskSituationDetected` (US-15). Cuando el adulto mayor no tiene ninguna regla activa para el tipo de registro capturado, el servicio lanza `NoMonitoringRuleConfiguredException`, que es la vía por la que el sistema comunica el error exigido en el segundo criterio de aceptación de esa misma historia. El repositorio expone la consulta del historial filtrada por rango de fechas y tipo de elemento (US-11, US-17).

\includegraphics[width=\linewidth]{assets/471-class-03-preventive-monitoring.png}

#### Bounded Context: Alerting

El agregado `Alert` implementa una máquina de estados de cuatro posiciones —`PENDING`, `IN_REVIEW`, `ATTENDED` y `CLOSED`— cuyas transiciones se validan en el método privado `ValidateTransition` y se rechazan mediante `InvalidAlertTransitionException`. Ninguna transición elimina el registro: cada cambio queda asentado como una entidad `AlertStatusChange` con el identificador del profesional que lo realizó y la marca temporal exacta, lo que satisface simultáneamente la conservación del historial (US-19) y la trazabilidad de la atención (US-18). Los métodos `IsReviewed` y `ReviewedBy` permiten distinguir en el frontend una alerta ya revisada de una sin revisar e indicar quién la atendió (US-14). El Domain Service `SeverityAssignmentService` asigna el nivel de gravedad al momento de crear la alerta (US-16), y el repositorio expone las consultas que alimentan el resumen inicial y el ordenamiento por urgencia (US-08, US-09).

\includegraphics[width=\linewidth]{assets/471-class-04-alerting.png}

#### Bounded Context: Care Coordination

El agregado `CareRecord` documenta la atención efectiva de una alerta. Se abre como reacción al evento `AlertStatusChanged`, previa validación de la especificación `CareRecordCreationPolicy`. El Value Object `Observation` encapsula el texto de la observación junto con su marca temporal y valida su longitud máxima en el propio constructor; al ser opcional, refleja que el criterio de aceptación define el campo de observación como opcional al cambiar el estado de la alerta (US-13). La enumeración `CareOutcome` tipifica el desenlace de la intervención, y los campos `careProviderId` y `attendedBy` conservan la trazabilidad hacia el profesional responsable (US-12, US-18).

\includegraphics[width=\linewidth]{assets/471-class-05-care-coordination.png}

#### Bounded Context: Notification

El agregado `Notification` modela cada mensaje individual dirigido a un destinatario por un canal concreto, con su propio estado de entrega y su contador de reintentos. El manejador `AlertRaisedHandler` reacciona al evento `AlertRaised` y consulta la especificación `ChannelSelectionPolicy`, que decide los canales a utilizar en función de la severidad: las alertas de gravedad alta se despachan por correo y SMS, mientras que las de gravedad media y baja se limitan al correo. El envío efectivo se delega en los puertos `IEmailSenderService` e `ISmsSenderService`, de modo que el dominio permanece independiente del proveedor contratado. El Value Object `DeliveryReceipt` traduce la confirmación del proveedor externo al lenguaje del dominio, actuando como Anti-Corruption Layer.

\includegraphics[width=\linewidth]{assets/471-class-06-notification.png}

#### Bounded Context: Marketing

El agregado `ContactRequest` recibe los formularios provenientes de la Landing Page. Es el contexto más simple del modelo: registra el lead, clasifica al interesado mediante `VisitorSegment` según provenga del botón de solicitud de información o del botón de registro como proveedor de salud (US-03, US-06), conserva opcionalmente la especialidad declarada y controla mediante `LeadStatus` si el mensaje ya fue atendido por el equipo comercial. La especificación `DuplicateLeadPolicy` evita registrar solicitudes repetidas del mismo correo dentro de una ventana de tiempo.

\includegraphics[width=\linewidth]{assets/471-class-07-marketing.png}
