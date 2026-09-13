## 4.6. Domain-Driven Software Architecture

La arquitectura de software de VitaLink se construye sobre los principios de Domain-Driven Design (DDD) y se documenta mediante el C4 Model, aplicando la técnica de Diagram-as-Code con Structurizr DSL. El modelo completo se mantiene versionado en el archivo `workspace.dsl` ubicado en la raíz del repositorio, de modo que cada diagrama presentado en esta sección se genera a partir de una única fuente de verdad y evoluciona junto con el código.

A partir del Big Picture EventStorming (sección 2.4) y del Ubiquitous Language (sección 2.5) se delimitaron seis bounded contexts, cada uno responsable de un conjunto cohesionado de reglas de negocio y de un único Aggregate Root:

| Bounded Context | Responsabilidad | Aggregate Root | User Stories |
|---|---|---|---|
| **Identity and Access Management** | Registro, autenticación y ciclo de vida de la cuenta de usuario; emisión y validación de tokens JWT. | `User` | US-06 |
| **Elder Care** | Perfiles del adulto mayor, del familiar y del proveedor de salud, y la vinculación entre ellos. | `OlderAdult` | US-20, US-21 |
| **Preventive Monitoring** | Registro de la información de salud, construcción del historial cronológico y evaluación de las reglas de monitoreo. | `HealthRecord` | US-11, US-15, US-17 |
| **Alerting** | Creación de la alerta, asignación del nivel de gravedad y ciclo de vida de sus estados. | `Alert` | US-08, US-09, US-15, US-16, US-19 |
| **Care Coordination** | Atención de la alerta, observaciones del profesional y trazabilidad de la intervención. | `CareRecord` | US-12, US-13, US-14, US-18 |
| **Notification** | Traducción de los eventos de dominio en notificaciones multicanal al familiar o al proveedor de salud. | `Notification` | — |

La comunicación entre contextos no se realiza mediante llamadas directas entre servicios, sino a través de un **Domain Event Publisher** que actúa como Shared Kernel: cada contexto publica sus eventos de dominio (`RiskSituationDetected`, `AlertRaised`, `AlertStatusChanged`, `AlertAttended`, `UserRegistered`) y los contextos interesados se suscriben a ellos. Este mecanismo mantiene el bajo acoplamiento entre bounded contexts y refleja directamente las políticas identificadas durante el EventStorming.

### 4.6.1. Design-Level Event Storming

### 4.6.2. Software Architecture Context Diagram

El System Context Diagram representa a VitaLink como una caja negra y delimita su frontera frente a los actores del dominio y a los sistemas externos de los que depende.

Se identifican tres actores, correspondientes a los términos definidos en el Ubiquitous Language:

1. **Older Adult:** el adulto mayor cuyo estado es monitoreado. Según lo establecido en el segmento objetivo 2 (sección 1.3), puede participar activamente en la plataforma consultando y registrando información sobre su propio estado.
2. **Family Caregiver:** el familiar o cuidador responsable del acompañamiento. Es el destinatario principal de las notificaciones de alerta y quien realiza el seguimiento del adulto mayor.
3. **Care Provider:** el profesional u organización de atención que revisa las alertas pendientes, consulta el historial y registra las observaciones de atención.

VitaLink depende de dos sistemas externos, ambos consumidos a través de una capa Anti-Corruption Layer (ACL) que aísla el modelo de dominio de los contratos de terceros:

* **Email Service:** servicio SMTP/API mediante el cual se envían las notificaciones transaccionales y los correos de verificación de cuenta.
* **SMS Gateway:** pasarela de mensajería utilizada como canal alternativo cuando la alerta generada es de gravedad alta, de modo que el familiar sea contactado aun cuando no tenga acceso al correo en ese momento.

Cabe precisar que la plataforma no notifica directamente al familiar: publica la solicitud de envío hacia el servicio correspondiente y es este el que entrega el mensaje al destinatario. Esta distinción queda explícita en el diagrama mediante la dirección de las relaciones.

\includegraphics[width=\linewidth]{assets/462-c4-context.png}

### 4.6.3. Software Architecture Container Diagrams

El Container Diagram descompone la plataforma en las unidades desplegables y ejecutables que la conforman. Cada contenedor corresponde a una unidad independiente de despliegue, y las tecnologías empleadas son las establecidas para el curso:

1. **Landing Page** (HTML5, CSS3, JavaScript): sitio web estático que constituye el punto de entrada público al producto. Comunica la propuesta de valor, la sección de privacidad y seguridad de datos, las preguntas frecuentes y el respaldo institucional, y capta las solicitudes de información. Atiende las historias US-01 a US-07.
2. **Web Application** (Vue 3, PrimeVue, Material Design): aplicación transaccional de página única. Ofrece el tablero de alertas del proveedor de salud y el panel de seguimiento del familiar. Atiende las historias US-08 a US-14.
3. **Backend REST API** (ASP.NET Core, C#, Entity Framework Core): expone los servicios de dominio bajo el estilo arquitectónico RESTful y concentra la totalidad de la lógica de negocio, organizada en los bounded contexts descritos al inicio de esta sección. Atiende las historias US-15 a US-21. Su documentación se publica mediante OpenAPI Specification vía Swagger.
4. **Relational Database** (PostgreSQL): almacenamiento transaccional de usuarios, perfiles, registros de salud, alertas, registros de atención y notificaciones. Se accede exclusivamente desde el Backend REST API mediante Entity Framework Core sobre el proveedor Npgsql, de modo que ningún contenedor cliente consulta la base de datos de forma directa.

La Landing Page y la Web Application se comunican con el Backend REST API mediante JSON sobre HTTPS. La Landing Page consume únicamente el endpoint público de solicitudes de información, mientras que la Web Application consume los endpoints protegidos, adjuntando el token JWT en cada petición autenticada.

\includegraphics[width=\linewidth]{assets/463-c4-containers.png}

### 4.6.4. Software Architecture Components Diagrams

Los Component Diagrams descomponen internamente los dos contenedores que concentran la lógica de la solución.

#### Componentes del Backend REST API

Los componentes del backend se encuentran agrupados visualmente por bounded context, de modo que la frontera lógica del modelo de dominio sea directamente observable en la estructura del código:

* **Security & JWT** e **Identity & Access** conforman el contexto de Identity and Access Management. El primero intercepta cada petición entrante, valida la firma del token y aplica la autorización por rol; el segundo gestiona el registro, la autenticación y el ciclo de vida de la cuenta.
* **Profiles** materializa el contexto Elder Care. Administra los perfiles de los tres actores y la asignación entre adulto mayor y proveedor de salud, permitiendo un único proveedor activo a la vez (US-20), y valida que los datos obligatorios estén completos antes de activar el seguimiento (US-21).
* **Health Monitoring** y **Risk Evaluation** conforman el contexto Preventive Monitoring. El primero persiste los registros de salud y construye el historial cronológico consultable por rango de fechas y tipo de elemento (US-11, US-17). El segundo es un servicio de dominio que evalúa cada registro recién capturado contra las reglas de monitoreo configuradas y, cuando se cumple una de ellas, publica el evento `RiskSituationDetected` (US-15).
* **Alerting** se suscribe a `RiskSituationDetected` y crea la alerta correspondiente, asignándole automáticamente su nivel de gravedad (US-16). Administra además el ciclo de vida de los estados pendiente, en revisión, atendida y cerrada, garantizando que ninguna transición elimine físicamente el registro (US-19).
* **Care Coordination** se suscribe a `AlertStatusChanged` y abre el registro de atención correspondiente, almacenando la observación del profesional junto con su identificador y la fecha y hora exacta del cambio (US-13, US-18). Esta información es la que permite distinguir en el frontend una alerta ya revisada de una sin revisar (US-14).
* **Notification** actúa como suscriptor transversal de los eventos de dominio y los traduce en notificaciones multicanal, delegando el envío en el Email Service o en el SMS Gateway según la gravedad de la alerta.
* **Contact & Leads** atiende el formulario de solicitud de información de la landing page y registra los leads generados (US-03, US-06).
* **Domain Event Publisher** constituye el Shared Kernel. Publica y enruta los eventos de dominio in-process hacia sus suscriptores, evitando que los bounded contexts se referencien entre sí de forma directa.

\includegraphics[width=\linewidth]{assets/464-c4-components-api.png}

#### Componentes de la Web Application

La aplicación de página única se organiza en cuatro capas de responsabilidad:

* **Router & Auth Guard** resuelve la navegación entre vistas y restringe cada ruta según el rol autenticado, consultando el estado de sesión antes de permitir el acceso.
* **Alert Views**, **Older Adult Views** y **Monitoring Views** agrupan las vistas por área funcional. Las primeras cubren el resumen de alertas pendientes, el listado ordenable por gravedad y el detalle de la alerta (US-08, US-09, US-12, US-13, US-14); las segundas, el perfil y el historial cronológico del adulto mayor (US-10, US-11); las terceras, el registro y la consulta de la información de salud.
* **State Store** centraliza el estado de sesión, las alertas cargadas y el perfil activo en el cliente, evitando peticiones redundantes al navegar entre vistas.
* **API Client** encapsula el consumo de la REST API, adjunta el token JWT a cada petición autenticada y normaliza el tratamiento de errores.

\includegraphics[width=\linewidth]{assets/464-c4-components-webapp.png}
