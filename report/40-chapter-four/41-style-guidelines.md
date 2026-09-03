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

