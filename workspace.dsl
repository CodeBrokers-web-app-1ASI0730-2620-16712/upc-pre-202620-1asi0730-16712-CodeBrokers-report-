workspace "VitaLink" "Modelo de arquitectura C4 de la plataforma VitaLink, desarrollada por la startup CodeBrokers para el monitoreo preventivo y acompanamiento de adultos mayores." {

    !identifiers hierarchical
    !impliedRelationships true

    model {

        # ---------------------------------------------------------------
        # Actores del dominio (Ubiquitous Language, seccion 2.5)
        # ---------------------------------------------------------------

        olderAdult = person "Older Adult" "Persona adulta mayor cuyo estado y seguimiento son gestionados mediante VitaLink. Puede consultar y registrar informacion sobre su propio estado."

        familyCaregiver = person "Family Caregiver" "Familiar o cuidador responsable de acompanar y realizar el seguimiento del adulto mayor. Recibe las notificaciones de alerta."

        careProvider = person "Care Provider" "Profesional u organizacion de atencion que revisa las alertas, consulta el historial del adulto mayor y registra observaciones de atencion."

        # ---------------------------------------------------------------
        # Sistemas externos
        # ---------------------------------------------------------------

        emailService = softwareSystem "Email Service" "Servicio SMTP/API utilizado para el envio de notificaciones transaccionales y la verificacion de cuentas." {
            tags "External System"
        }

        smsGateway = softwareSystem "SMS Gateway" "Pasarela de mensajeria SMS utilizada como canal alternativo cuando la alerta es de gravedad alta." {
            tags "External System"
        }

        # ---------------------------------------------------------------
        # Sistema VitaLink
        # ---------------------------------------------------------------

        vitalink = softwareSystem "VitaLink Platform" "Plataforma digital de monitoreo preventivo y acompanamiento de adultos mayores. Centraliza la informacion de salud, detecta situaciones de riesgo, genera alertas y coordina la atencion entre familiares y proveedores de salud." {

            landing = container "Landing Page" "Sitio web estatico de marketing y captacion. Comunica la propuesta de valor, la politica de privacidad y capta solicitudes de informacion. Punto de entrada publico al producto." "HTML5, CSS3, JavaScript" {
                tags "Web Browser"
            }

            spa = container "Web Application" "Aplicacion transaccional de pagina unica. Ofrece el tablero de alertas del proveedor de salud y el panel de seguimiento del familiar." "Vue 3, PrimeVue, Material Design" {
                tags "Web Browser"

                router = component "Router & Auth Guard" "Resuelve la navegacion entre vistas y restringe cada ruta segun el rol autenticado." "Vue Router"
                alertViews = component "Alert Views" "Vistas de resumen de alertas pendientes, listado ordenable por gravedad y detalle de la alerta. (US-08, US-09, US-12, US-13, US-14)" "Vue 3, PrimeVue"
                olderAdultViews = component "Older Adult Views" "Vistas de perfil e historial cronologico del adulto mayor. (US-10, US-11)" "Vue 3, PrimeVue"
                monitoringViews = component "Monitoring Views" "Vistas de registro y consulta de la informacion de salud del adulto mayor." "Vue 3, PrimeVue"
                stateStore = component "State Store" "Mantiene el estado de sesion, las alertas cargadas y el perfil activo en el cliente." "Pinia"
                apiClient = component "API Client" "Encapsula el consumo de la REST API, adjunta el token JWT y normaliza los errores." "Axios"
            }

            api = container "Backend REST API" "Expone los servicios de dominio bajo el estilo arquitectonico RESTful. Organiza la logica en bounded contexts segun Domain-Driven Design." "ASP.NET Core, C#, Entity Framework Core" {

                group "Identity and Access Management" {
                    security = component "Security & JWT" "Emite y valida los tokens JWT y aplica la autorizacion por rol en cada peticion entrante." "ASP.NET Core Authentication"
                    identityAccess = component "Identity & Access" "Registro, autenticacion y ciclo de vida de la cuenta de usuario. Agregado: User. (US-06)" "ASP.NET Core Web API"
                }

                group "Elder Care Context" {
                    profiles = component "Profiles" "Perfiles del adulto mayor, del familiar y del proveedor de salud, y la vinculacion entre ellos. Valida los datos obligatorios antes de activar el seguimiento. Agregados: OlderAdult, FamilyCaregiver, CareProvider, CaregiverAssignment. (US-20, US-21)" "ASP.NET Core Web API"
                }

                group "Preventive Monitoring Context" {
                    healthMonitoring = component "Health Monitoring" "Registro de la informacion de salud y construccion del historial cronologico del adulto mayor, consultable por rango de fechas y tipo de elemento. Agregado: HealthRecord. (US-11, US-15, US-17)" "ASP.NET Core Web API"
                    riskEvaluation = component "Risk Evaluation" "Servicio de dominio que evalua cada registro contra las reglas de monitoreo configuradas y determina si constituye una situacion de riesgo. Agregado: MonitoringRule. (US-15)" "Domain Service"
                }

                group "Alerting Context" {
                    alerting = component "Alerting" "Creacion de la alerta a partir de una situacion de riesgo, asignacion del nivel de gravedad y ciclo de vida de estados (pendiente, en revision, atendida, cerrada) sin borrado fisico. Agregado: Alert. (US-08, US-09, US-15, US-16, US-19)" "ASP.NET Core Web API"
                }

                group "Care Coordination Context" {
                    careCoordination = component "Care Coordination" "Registro de la atencion de la alerta, observaciones del profesional y trazabilidad de quien atendio y cuando. Agregado: CareRecord. (US-12, US-13, US-14, US-18)" "ASP.NET Core Web API"
                }

                group "Notification Context" {
                    notification = component "Notification" "Suscriptor de eventos de dominio. Traduce cada evento relevante en una notificacion multicanal dirigida al familiar o al proveedor de salud. Agregado: Notification." "ASP.NET Core Hosted Service"
                }

                group "Marketing Context" {
                    contactLeads = component "Contact & Leads" "Solicitudes de informacion y leads provenientes de la landing page. Agregado: ContactRequest. (US-03, US-06)" "ASP.NET Core Web API"
                }

                group "Shared Kernel" {
                    eventPublisher = component "Domain Event Publisher" "Desacopla los bounded contexts publicando y enrutando los eventos de dominio in-process hacia sus suscriptores." "MediatR"
                }
            }

            db = container "Relational Database" "Almacenamiento transaccional de usuarios, perfiles, registros de salud, alertas, observaciones de atencion y notificaciones." "PostgreSQL" {
                tags "Database"
            }
        }

        # ---------------------------------------------------------------
        # Relaciones: personas hacia el sistema
        # ---------------------------------------------------------------

        careProvider -> vitalink.landing "Visita para conocer la propuesta de valor y solicitar informacion" "HTTPS"
        familyCaregiver -> vitalink.landing "Visita para conocer la propuesta de valor y la politica de privacidad" "HTTPS"

        familyCaregiver -> vitalink.spa "Registra al adulto mayor y realiza el seguimiento de su estado" "HTTPS"
        careProvider -> vitalink.spa "Revisa las alertas pendientes, consulta el historial y registra observaciones" "HTTPS"
        olderAdult -> vitalink.spa "Consulta y registra informacion sobre su propio estado" "HTTPS"

        emailService -> familyCaregiver "Notifica las alertas generadas y las confirmaciones de atencion" "Email"
        emailService -> careProvider "Notifica las alertas asignadas a su cargo" "Email"
        smsGateway -> familyCaregiver "Notifica las alertas de gravedad alta" "SMS"

        # ---------------------------------------------------------------
        # Relaciones: entre contenedores
        # ---------------------------------------------------------------

        vitalink.landing -> vitalink.spa "Deriva al flujo de registro e inicio de sesion" "HTTPS"

        # ---------------------------------------------------------------
        # Relaciones: componentes de la Web Application
        # ---------------------------------------------------------------

        vitalink.spa.router -> vitalink.spa.alertViews "Resuelve la ruta del tablero de alertas"
        vitalink.spa.router -> vitalink.spa.olderAdultViews "Resuelve la ruta del perfil e historial"
        vitalink.spa.router -> vitalink.spa.monitoringViews "Resuelve la ruta de registro de informacion de salud"
        vitalink.spa.router -> vitalink.spa.stateStore "Consulta la sesion activa y el rol para autorizar la ruta"

        vitalink.spa.alertViews -> vitalink.spa.stateStore "Lee y actualiza el estado de las alertas"
        vitalink.spa.olderAdultViews -> vitalink.spa.stateStore "Lee el perfil y el historial cargados"
        vitalink.spa.monitoringViews -> vitalink.spa.stateStore "Lee y actualiza los registros de salud"
        vitalink.spa.stateStore -> vitalink.spa.apiClient "Solicita y persiste los datos del dominio"

        vitalink.spa.apiClient -> vitalink.api.security "Envia el token JWT en cada peticion autenticada" "JSON/HTTPS"
        vitalink.spa.apiClient -> vitalink.api.identityAccess "POST /api/v1/authentication/sign-up y sign-in" "JSON/HTTPS"
        vitalink.spa.apiClient -> vitalink.api.profiles "GET, POST y PUT /api/v1/older-adults y /api/v1/care-providers" "JSON/HTTPS"
        vitalink.spa.apiClient -> vitalink.api.healthMonitoring "POST y GET /api/v1/older-adults/{id}/health-records" "JSON/HTTPS"
        vitalink.spa.apiClient -> vitalink.api.alerting "GET /api/v1/alerts y PATCH /api/v1/alerts/{id}/status" "JSON/HTTPS"
        vitalink.spa.apiClient -> vitalink.api.careCoordination "POST y GET /api/v1/alerts/{id}/care-records" "JSON/HTTPS"

        vitalink.landing -> vitalink.api.contactLeads "POST /api/v1/contact-requests" "JSON/HTTPS"

        # ---------------------------------------------------------------
        # Relaciones: componentes del Backend REST API
        # ---------------------------------------------------------------

        vitalink.api.security -> vitalink.api.identityAccess "Valida las credenciales y resuelve los roles del usuario"

        vitalink.api.healthMonitoring -> vitalink.api.riskEvaluation "Solicita la evaluacion del registro recien capturado"
        vitalink.api.riskEvaluation -> vitalink.api.eventPublisher "Publica RiskSituationDetected cuando el registro cumple una regla"
        vitalink.api.eventPublisher -> vitalink.api.alerting "Entrega RiskSituationDetected para la creacion de la alerta"

        vitalink.api.alerting -> vitalink.api.profiles "Resuelve el adulto mayor y el proveedor de salud vinculado"
        vitalink.api.alerting -> vitalink.api.eventPublisher "Publica AlertRaised y AlertStatusChanged"
        vitalink.api.eventPublisher -> vitalink.api.careCoordination "Entrega AlertStatusChanged para abrir el registro de atencion"
        vitalink.api.careCoordination -> vitalink.api.eventPublisher "Publica AlertAttended"

        vitalink.api.identityAccess -> vitalink.api.eventPublisher "Publica UserRegistered"
        vitalink.api.contactLeads -> vitalink.api.eventPublisher "Publica ContactRequestReceived"
        vitalink.api.eventPublisher -> vitalink.api.notification "Entrega los eventos de dominio suscritos"

        vitalink.api.notification -> emailService "Solicita el envio del correo" "SMTP/API - ACL"
        vitalink.api.notification -> smsGateway "Solicita el envio del SMS" "REST/HTTPS - ACL"

        # ---------------------------------------------------------------
        # Relaciones: persistencia
        # ---------------------------------------------------------------

        vitalink.api.identityAccess -> vitalink.db "Persiste y recupera su Aggregate Root" "EF Core / Npgsql"
        vitalink.api.profiles -> vitalink.db "Persiste y recupera sus Aggregate Roots" "EF Core / Npgsql"
        vitalink.api.healthMonitoring -> vitalink.db "Persiste y recupera su Aggregate Root" "EF Core / Npgsql"
        vitalink.api.riskEvaluation -> vitalink.db "Lee las reglas de monitoreo configuradas" "EF Core / Npgsql"
        vitalink.api.alerting -> vitalink.db "Persiste y recupera su Aggregate Root" "EF Core / Npgsql"
        vitalink.api.careCoordination -> vitalink.db "Persiste y recupera su Aggregate Root" "EF Core / Npgsql"
        vitalink.api.notification -> vitalink.db "Persiste el historial de notificaciones enviadas" "EF Core / Npgsql"
        vitalink.api.contactLeads -> vitalink.db "Persiste los mensajes de contacto" "EF Core / Npgsql"
    }

    views {

        systemContext vitalink "C4-01-Context" "Diagrama de Contexto de la plataforma VitaLink." {
            include *
            autolayout tb
        }

        container vitalink "C4-02-Containers" "Diagrama de Contenedores de la plataforma VitaLink." {
            include *
            autolayout tb
        }

        component vitalink.api "C4-03-Components-API" "Diagrama de Componentes del Backend REST API, organizado por bounded contexts." {
            include *
            autolayout tb
        }

        component vitalink.spa "C4-04-Components-WebApp" "Diagrama de Componentes de la Web Application." {
            include *
            autolayout tb
        }

        styles {
            element "Person" {
                shape Person
                background #0b5394
                color #ffffff
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "External System" {
                background #808080
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Web Browser" {
                shape WebBrowser
            }
            element "Database" {
                shape Cylinder
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
        }
    }
}
