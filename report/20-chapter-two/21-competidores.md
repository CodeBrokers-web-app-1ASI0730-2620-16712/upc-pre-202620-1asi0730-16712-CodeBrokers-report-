# Capítulo II: Requirements Elicitation & Analysis

## 2.1. Competidores

Para el análisis de competidores se priorizó la identificación de soluciones digitales con un modelo de negocio similar al de VitaLink: aplicaciones orientadas al monitoreo remoto de adultos mayores y a la conexión entre el adulto mayor, sus familiares/cuidadores y, en algunos casos, proveedores de atención. Dado que en el mercado peruano no se identificaron startups comerciales activas con una oferta equivalente (solo iniciativas académicas no comercializadas), se consideraron competidores directos de alcance internacional/regional, cuya propuesta de valor es comparable a la de VitaLink.

Los competidores identificados son:

1. **cuYdo** (España) — aplicación móvil que, mediante sensores instalados en el hogar, permite a familiares y cuidadores conocer en tiempo real la situación del adulto mayor que vive solo, sin uso de cámaras.

\includegraphics[width=\linewidth]{assets/21-competidores-cuydo.png}

2. **CuidApp** (Argentina) — aplicación orientada a coordinar el cuidado de un adulto mayor entre un "cuidador principal" y un grupo de "ayudantes" (familiares/cuidadores secundarios).

\includegraphics[width=\linewidth]{assets/21-competidores-cuidapp.png}

3. **Silver-Digi** (España) — aplicación que facilita la independencia de adultos mayores mediante videollamadas automáticas con cuidadores/familiares y monitoreo remoto de datos de sensores.

\includegraphics[width=\linewidth]{assets/21-competidores-silverdigi.png}

### 2.1.1. Análisis competitivo

**Competitive Analysis Landscape**

¿Por qué llevar a cabo este análisis? Conocer cómo VitaLink se posiciona frente a soluciones existentes de monitoreo y acompañamiento de adultos mayores, en términos de propuesta de valor, alcance funcional y modelo comercial, para reforzar su ventaja competitiva.

| Grupo | Aspecto | **VitaLink** | **cuYdo** | **CuidApp** | **Silver-Digi** |
|---|---|---|---|---|---|
| Perfil | Overview | Plataforma de CodeBrokers que centraliza el estado de salud del adulto mayor y conecta a familiares y proveedores de salud mediante alertas preventivas. | App para familiares de adultos mayores que viven solos, basada en sensores de movimiento en el hogar que aprenden rutinas y detectan posibles riesgos.Para el funcionamiento de cuYdo se realiza una sencilla instalación de sensores inalámbricos que se pegan en las principales estancias de la vivienda de la persona mayor, con estos sensores cuYdo aprende los hábitos y rutinas de cada persona mayor, a partir de los cuales determina cuándo se produce una situación de posible peligro. | App de coordinación del cuidado, organizada en torno a un cuidador principal (administrador) y un grupo de cuidadores secundarios (ayudantes) con acceso a la información del adulto mayor.La App está pensada para la persona que tiene a su cargo el cuidado de un adulto mayor, que será el Administrador de la aplicación, llamado "Cuidador principal", y otros usuarios habilitados por el Administrador, llamados "Ayudantes", que pasan a formar parte del "Grupo de cuidadores". | App que promueve la independencia de adultos mayores de 65+ mediante videollamadas automáticas y monitoreo remoto de sensores para cuidadores y familiares.Silver-Digi está diseñada para promover la independencia y el bienestar de las personas mayores de 65 años, facilitando la conexión con cuidadores profesionales y familiares mediante videollamadas automáticas y monitorización remota de datos de sensores. |
| Perfil | Ventaja competitiva | Integra en un mismo ecosistema al adulto mayor, la red familiar y proveedores de salud (clínicas/hospitales), no solo el entorno familiar. | Detección de patrones de riesgo sin cámaras, preservando la privacidad del adulto mayor. | Estructura simple de roles (principal/ayudantes) que facilita la coordinación entre varios cuidadores. | Interacción por videollamada automática, pensada para adultos mayores con baja alfabetización digital. |
| Perfil | ¿Qué valor ofrece a los clientes? | Tranquilidad familiar, detección temprana de riesgos y canal directo con proveedores de salud. | Tranquilidad sobre la seguridad del adulto mayor en su propio hogar. | Organización y reparto de responsabilidades de cuidado entre varios familiares. | Compañía, supervisión remota y reducción de la brecha digital para el adulto mayor. |
| Perfil de Marketing | Mercado objetivo | Familias con adultos mayores de 60+ en Lima Metropolitana y ciudades del Perú; clínicas y hospitales. | Familiares de adultos mayores que viven solos (España/Europa). | Familias con más de un cuidador involucrado (Argentina/Latinoamérica). | Adultos mayores 65+ y sus cuidadores/familiares (España). |
| Perfil de Marketing | Estrategias de marketing | Landing page con call-to-action segmentado (familiares vs. proveedores de salud), alianzas con clínicas. | Difusión a través de fundaciones y programas de buenas prácticas en cuidado de mayores. | Distribución vía tiendas de aplicaciones (Google Play / App Store). | Distribución vía App Store, enfocada en accesibilidad y facilidad de uso. |
| Perfil de Producto | Productos & Servicios | App web/móvil de monitoreo preventivo, sistema de alertas, panel de seguimiento, canal de comunicación con proveedores. | App móvil + kit de sensores para el hogar. | App móvil de coordinación de cuidados y grupo de cuidadores. | App (solo iOS) + tablet con descuelgue automático para videollamadas. |
| Perfil de Producto | Precios & Costos | Modelo a definir (freemium para familiares, planes para clínicas). | No publica precios de forma abierta; requiere instalación de hardware. | Información no publicada públicamente. | Aplicación gratuita; costo de la tablet/hardware no publicado. |
| Perfil de Producto | Canales de distribución (Web y/o Móvil) | Landing Page + Web Application (responsive). | Aplicación móvil (Android/iOS). | Aplicación móvil (Android/iOS). | Aplicación móvil (solo iOS). |

**Análisis SWOT**

| Categoría | **VitaLink** | **cuYdo** | **CuidApp** | **Silver-Digi** |
|---|---|---|---|---|
| Fortalezas | Integra familiares y proveedores de salud en un mismo ecosistema; enfoque preventivo con sistema de alertas automáticas. | Detección de riesgos sin cámaras, preservando la privacidad del adulto mayor. | Modelo simple de roles entre cuidadores (principal/ayudantes). | Interfaz pensada para reducir la brecha digital del adulto mayor. |
| Debilidades | Producto aún en fase de validación, sin usuarios reales ni alianzas confirmadas con clínicas u hospitales. | Depende de instalación física de sensores en el hogar. | No incorpora un sistema de alertas ni conexión con proveedores de salud. | Disponible solo para iOS, lo que limita su alcance. |
| Oportunidades | Crecimiento acelerado de la población adulta mayor en el Perú; ausencia de un competidor local consolidado. | Expansión a mercados latinoamericanos. | Alta necesidad de coordinación familiar en el cuidado del adulto mayor. | Interés creciente en soluciones de acompañamiento remoto por videollamada. |
| Amenazas | Adopción tecnológica limitada en adultos mayores; ingreso de competidores internacionales (cuYdo, Silver-Digi) al mercado peruano. | Soluciones basadas solo en software (como VitaLink), sin hardware, con menor fricción de adopción. | Plataformas con enfoque preventivo/predictivo (como VitaLink) que ofrecen mayor valor agregado. | Soluciones multiplataforma y con mayor cobertura funcional (alertas + panel + proveedores de salud). |


### 2.1.2. Estrategias y tácticas frente a competidores

Con base en el análisis competitivo anterior, CodeBrokers adoptará las siguientes estrategias y tácticas preliminares para VitaLink:

- **Frente a la falta de conexión con proveedores de salud (debilidad común en cuYdo, CuidApp y Silver-Digi):** posicionar como diferenciador principal el canal de comunicación directo entre familiares y clínicas/hospitales, resaltándolo en la Landing Page y en el flujo de onboarding.
- **Frente a la dependencia de hardware de cuYdo:** comunicar que VitaLink no requiere instalación de sensores físicos, reduciendo la fricción de adopción y el costo inicial para las familias.
- **Frente a la limitación de plataforma de Silver-Digi (solo iOS):** desarrollar la Web Application con diseño responsive, accesible desde cualquier dispositivo, ampliando el alcance a segmentos con menor poder adquisitivo.
- **Frente a la baja adopción tecnológica en adultos mayores (amenaza para todo el mercado):** diseñar una interfaz simple e inclusiva (a11y) dirigida principalmente a familiares/cuidadores como usuarios primarios, sin exigir que el adulto mayor interactúe directamente con la plataforma.
- **Frente al posible ingreso de competidores internacionales al mercado peruano (amenaza):** priorizar alianzas tempranas con clínicas y hospitales locales como barrera de entrada, aprovechando que VitaLink nace con enfoque en el ecosistema de salud peruano.
- **Aprovechando la ausencia de un competidor local consolidado (oportunidad):** enfocar la estrategia de marketing inicial en Lima Metropolitana, apoyándose en el crecimiento de la población adulta mayor en el país.