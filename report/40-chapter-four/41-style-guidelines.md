# 4. Capítulo IV: Product Design

## 4.1. Style Guidelines 

El diseño visual de la aplicación VitaLink sigue una estética entre lo clínico y lo confiable, esto porque va relacionado a la identidad que tiene el startup BrokerCodes y el compromiso que tenemos por ofrecer soluciones de calidad hacia el sector salud, enfocadas en el cuidado y acompañamiento de adultos mayores.

Es por esto que, en este capítulo, describiremos cada uno de los detalles y estilos que estaremos utilizando al momento de desarrollar la aplicación (siguiendo los principios UX y UI).

### 4.1.1. General Style Guidelines

**Branding**

El logo principal representa a Vitalink, una plataforma orientada al monitoreo y seguimiento de la salud de los adultos mayores. El nombre surge de la combinación de “Vital”, relacionado con los signos vitales, la salud y el bienestar, y “Link”, que representa la conexión constante entre el adulto mayor, sus familiares y los profesionales o centros de salud.

La identidad visual incorpora un ícono minimalista que combina elementos relacionados con la salud, el monitoreo y la conexión. El símbolo representa una figura humana protegida dentro de una forma inspirada en un corazón, integrando además una línea de pulso o electrocardiograma. Este recurso visual comunica de manera directa el propósito de Vitalink: cuidar, monitorear y mantener conectadas a las personas involucradas en el bienestar del adulto mayor.

\includegraphics[width=0.7\linewidth]{assets/logo-vitalink.png}

**Typography**

La tipografía principal empleada será Arial, utilizando sus variantes Regular, SemiBold y Bold.

La elección de esta tipografía se debe principalmente a su alta legibilidad, simplicidad y compatibilidad con diferentes dispositivos tecnológicos, como ordenadores, tabletas y teléfonos móviles. Esto resulta especialmente importante para Vitalink, ya que la plataforma puede ser utilizada por adultos mayores, familiares y profesionales de la salud.

El uso de una tipografía clara y fácil de leer permitirá que la información relacionada con signos vitales, alertas, estados de salud y otros datos importantes pueda ser comprendida rápidamente.

El tamaño de letra utilizado en la aplicación seguirá la siguiente distribución:

Títulos principales: 2.25rem (36px), utilizados para encabezados principales y secciones importantes.
Subtítulos: entre 1.5rem (24px) y 1.75rem (28px), utilizados para organizar las diferentes secciones de información.
Texto secundario: entre 1.125rem (18px) y 1.25rem (20px), especialmente recomendado para información relevante o elementos que requieran mayor visibilidad.
Cuerpo del texto: 1rem (16px), acompañado de un interlineado aproximado de 1.5 a 1.6 para facilitar la lectura.
Información auxiliar: 0.875rem (14px), utilizada para etiquetas, fechas, información complementaria o textos secundarios.

La tipografía y los colores serán utilizados manteniendo un contraste adecuado entre el texto y el fondo, buscando cumplir con un ratio mínimo de 4.5:1, de acuerdo con las recomendaciones de accesibilidad WCAG 2.1 AA.

### Paleta de Colores y Jerarquía Visual

#### 1. Paleta Principal
* **Verde Vitalink (#1D9E75):** Funciona como color principal de la marca y se utiliza en botones, elementos interactivos, indicadores y componentes destacados.

#### 2. Paleta Secundaria
* **Verde Oscuro (#0F6E56):** Se utiliza como color complementario para reforzar elementos de la interfaz y generar diferentes niveles de jerarquía visual.
* **Neutro Claro (#F8FAFB):** Funciona como base para fondos y superficies, permitiendo mantener una interfaz limpia y facilitar la lectura del contenido.

#### 3. Colores Funcionales
* **Tonos verdes:** Se utilizan principalmente para representar estados positivos, información correcta, bienestar y confirmaciones dentro de la aplicación. Estos colores permiten comunicar visualmente información relevante sin sobrecargar la interfaz.

#### 4. Neutrales
* **Tonos neutros:** Se utilizan para fondos, tarjetas, separadores y elementos secundarios, creando contraste con los colores principales y manteniendo una apariencia limpia y profesional.

\includegraphics[width=0.7\linewidth]{assets/colors.png}


### Spacing
El sistema de spacing mantiene una estructura consistente para conseguir una interfaz ordenada, profesional y fácil de utilizar:

* **Spacing base de 0.5 rem (8 px)** para mantener consistencia y ritmo visual entre los diferentes elementos de la aplicación.
* **Padding interno de 1.5 rem a 3.75 rem (24–60 px)** en tarjetas, contenedores y secciones principales, proporcionando suficiente espacio para evitar una apariencia sobrecargada.
* **Separación entre secciones de 3.75 rem a 5 rem (60–80 px)** para establecer una jerarquía clara entre los diferentes bloques de contenido.
* **Spacing entre elementos relacionados de 0.5 rem a 1.875 rem (8–30 px)**, dependiendo de su nivel de relación y jerarquía.
* **Componentes interactivos:** Mantienen un espacio suficiente alrededor de ellos para facilitar la navegación y mejorar la experiencia de usuario.

### Tono de Comunicación
La comunicación de Vitalink Professional busca transmitir profesionalismo, confianza y cercanía, utilizando un lenguaje sencillo que permita al usuario comprender rápidamente la información proporcionada.

* **Equilibrio:** Profesional pero accesible (75% formal, 25% cercano), proyectando una imagen confiable sin generar una comunicación excesivamente rígida.
* **Actitud:** Segura, clara y positiva (85% profesional, 15% entusiasta), especialmente en mensajes relacionados con acciones, resultados y mejoras.
* **Lenguaje:** Directo, claro y orientado a beneficios, evitando términos técnicos innecesarios y priorizando información que pueda ser comprendida rápidamente.
* **Voz:** Profesional, confiable y orientada al bienestar, posicionando Vitalink Professional como una herramienta que facilita la gestión y permite tomar decisiones basadas en información clara.

### 4.1.2. Web Style Guidelines

Esta sección describe los lineamientos visuales comunes aplicados a las diferentes vistas de la landing page de VitaLink, manteniendo una identidad visual coherente independientemente del tipo de usuario al que esté dirigida cada vista. Aunque el contenido y algunos elementos pueden adaptarse según el perfil del usuario, ambas mantienen los mismos principios de diseño en cuanto a colores, tipografía, estructura, componentes, iconografía, espaciado y tono comunicacional. La propuesta busca transmitir una imagen de tecnología aplicada a la salud, confianza, seguridad y facilidad de uso.

### Botones y Elementos de Acción
* **Color principal:** Verde médico (#00694C), utilizado como color predominante para las acciones principales.
* **Estados de interacción:** Se utiliza el verde secundario (#008560) para estados hover y elementos destacados.
* **Tipografía:** Inter, con peso semibold o bold, favoreciendo una lectura clara.
* **Color del texto:** Blanco (#FFFFFF) sobre botones de color verde y gris oscuro (#191C1D) sobre botones secundarios.
* **Forma:** Esquinas redondeadas, principalmente entre 12px y 16px, manteniendo una apariencia moderna y amigable.
* **Estilo:** Los botones principales pueden incorporar sombras sutiles y transiciones para reforzar su jerarquía.
* **Tono comunicacional:** Directo, profesional y orientado a la acción, utilizando textos claros que indican al usuario qué puede realizar.

### Enlaces de Navegación
* **Color:** Los enlaces utilizan tonos gris verdoso (#3D4943) y cambian al verde principal (#00694C) durante la interacción.
* **Tipografía:** Inter, principalmente con peso semibold.
* **Estilo:** Sin subrayado, con espaciado suficiente entre elementos para facilitar la navegación.
* **Jerarquía:** La navegación diferencia claramente los elementos principales de los secundarios.
* **Tono:** Claro, profesional y sencillo, permitiendo al usuario identificar rápidamente las diferentes secciones de la plataforma.

### Header
* **Estructura:** Ambas vistas mantienen un encabezado superior como elemento principal de navegación e identificación de la plataforma.
* **Identidad:** El logotipo y el nombre de VitaLink se mantienen como elementos fundamentales de reconocimiento de marca.
* **Fondo:** Predominio de superficies claras, principalmente blanco (#FFFFFF) o tonos neutros muy claros.
* **Posición:** El encabezado se mantiene en la parte superior y presenta una separación visual respecto al contenido.
* **Navegación:** Incluye accesos a las principales secciones y acciones relevantes para el usuario.
* **Estilo:** Limpio, minimalista y organizado, evitando una sobrecarga de elementos.
* **Tono:** Confiable, profesional y accesible.

### Estructura de las Secciones
* **Distribución:** Las diferentes vistas mantienen una estructura organizada mediante bloques de contenido claramente diferenciados.
* **Fondos:** Se combinan superficies blancas (#FFFFFF) con fondos neutros claros como #F8FAFB, #F2F4F5 y #ECEEEF para establecer separación entre secciones.
* **Espaciado:** Se utiliza un espaciado amplio entre bloques, proporcionando una experiencia visual limpia y evitando la saturación de información.
* **Contenedores:** El contenido se organiza dentro de áreas de ancho limitado para mejorar la legibilidad y mantener una composición equilibrada.
* **Jerarquía:** Cada sección presenta títulos, textos descriptivos, elementos visuales o componentes interactivos claramente diferenciados.
* **Tono:** Ordenado, profesional y fácil de comprender.

### Tarjetas y Contenedores
* **Fondo:** Blanco (#FFFFFF), principalmente sobre superficies neutras.
* **Bordes:** Gris claro (#E1E3E4) para delimitar los componentes.
* **Forma:** Esquinas redondeadas, generalmente de 16px.
* **Sombras:** Sombras suaves utilizadas para generar profundidad y separar visualmente las tarjetas del fondo.
* **Contenido:** Permiten organizar información, funcionalidades, beneficios o elementos relacionados con la plataforma.
* **Estilo:** Minimalista, evitando decoraciones innecesarias y priorizando la información.
* **Tono:** Profesional, limpio y confiable.

### Tipografía
* **Familia:** Inter, utilizada como tipografía principal en las diferentes vistas.
* **Títulos principales:** Tamaños grandes, aproximadamente 48px, con peso bold.
* **Títulos de sección:** Aproximadamente 32px, con peso semibold.
* **Subtítulos:** Aproximadamente 24px, con peso semibold.
* **Texto principal:** 16px, con peso regular.
* **Texto destacado:** 18px para descripciones o mensajes de mayor importancia.
* **Etiquetas:** Entre 11px y 14px, utilizando pesos medium o semibold.
* **Características:** La tipografía mantiene una jerarquía visual clara y una buena legibilidad tanto para contenidos informativos como para elementos interactivos.

### Iconografía
* **Estilo:** Lineal, minimalista y funcional.
* **Sistema:** Material Symbols.
* **Uso:** Los iconos acompañan botones, tarjetas, alertas, funcionalidades y elementos de navegación.
* **Tamaño:** Se adapta según la jerarquía del componente, desde aproximadamente 18px en elementos pequeños hasta 40px o más en elementos destacados.
* **Colores:** Predominan el verde principal (#00694C), azul secundario (#416089), verde terciario (#026951) y rojo (#BA1A1A) para situaciones de alerta.
* **Tono:** Funcional y fácil de interpretar, complementando el contenido textual sin sustituirlo.

### Elementos Visuales e Imágenes
* **Estilo:** Las imágenes utilizadas buscan representar el contexto tecnológico y sanitario de VitaLink.
* **Presentación:** Las imágenes se integran dentro de contenedores con bordes redondeados y sombras sutiles.
* **Composición:** Se utilizan elementos visuales junto al contenido textual para facilitar la comprensión de la propuesta de valor.
* **Interacción:** Algunos elementos visuales incorporan transiciones o movimientos sutiles para aportar dinamismo.
* **Tono:** Moderno, tecnológico y profesional, reforzando la relación entre salud y tecnología.

### Alertas y Estados
* **Color de alerta:** Rojo (#BA1A1A), utilizado para representar situaciones que requieren atención.
* **Fondo:** Rojo claro (#FFDAD6) en los componentes que requieren destacar una situación crítica.
* **Iconografía:** Se emplean símbolos relacionados con notificaciones, signos vitales o situaciones de atención.
* **Uso:** Las alertas se presentan como elementos visualmente diferenciados para facilitar su identificación.
* **Tono:** Claro, preventivo e inmediato, evitando elementos visuales excesivamente agresivos.

### Paleta de Colores Común
* **Verde principal (#00694C):** Identidad principal de VitaLink y acciones importantes.
* **Verde secundario (#008560):** Estados de interacción y elementos destacados.
* **Verdes claros (#68DBAE y #86F8C9):** Acentos y elementos decorativos.
* **Azul secundario (#416089):** Elementos complementarios y tecnológicos.
* **Verde terciario (#026951 y #2D8269):** Elementos asociados a salud y seguridad.
* **Blanco (#FFFFFF):** Fondos, tarjetas y superficies principales.
* **Fondo neutro (#F8FAFB, #F2F4F5 y #ECEEEF):** Diferenciación entre secciones.
* **Gris claro (#E1E3E4):** Bordes y separadores.
* **Gris verdoso (#3D4943):** Textos secundarios.
* **Gris oscuro (#191C1D):** Títulos y textos principales.
* **Rojo (#BA1A1A):** Alertas y situaciones críticas.

### Espaciado y Bordes
* **Unidad base:** 8px como referencia para mantener consistencia en márgenes y separaciones.
* **Separación entre secciones:** Espacios amplios, aproximadamente 80px en secciones principales.
* **Márgenes:** Adaptados según el dispositivo, utilizando aproximadamente 40px en escritorio y 20px en dispositivos móviles.
* **Bordes:** Predominan bordes suaves y discretos.
* **Radios:** Se utilizan esquinas redondeadas en botones, tarjetas, imágenes y contenedores.
* **Objetivo:** Mantener una apariencia uniforme y facilitar la lectura visual de los contenidos.

### Diseño Responsivo
* **Adaptabilidad:** Las dos vistas mantienen los mismos principios visuales independientemente del tamaño de pantalla.
* **Escritorio:** Se aprovechan distribuciones de varias columnas para organizar contenido, imágenes y componentes.
* **Dispositivos móviles:** Los elementos se reorganizan verticalmente, priorizando la legibilidad y las acciones principales.
* **Navegación:** Algunos elementos secundarios pueden ocultarse o reorganizarse para evitar saturación.
* **Objetivo:** Garantizar una experiencia consistente y funcional en diferentes dispositivos.

### Tono Comunicacional General
Profesional, claro, confiable y empático. Ambas vistas utilizan un lenguaje orientado a la salud y la tecnología, buscando transmitir seguridad y confianza sin generar una percepción excesivamente técnica o compleja. La comunicación prioriza mensajes directos, beneficios concretos y llamados a la acción fácilmente identificables.

En conjunto, los elementos comunes permiten que las diferentes vistas sean reconocidas como parte de un mismo producto digital. La consistencia en la paleta de colores, tipografía, botones, iconografía, espaciado, tarjetas, bordes y estructura visual permite que VitaLink mantenga una identidad unificada, aun cuando el contenido y las funcionalidades presentadas puedan variar según el tipo de usuario.