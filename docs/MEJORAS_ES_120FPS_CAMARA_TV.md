# GameplayFootball 2026/27 — interfaz española, FPS y televisión

## Cambios
- Pantalla 16:9 correcta, Home reducido con motivos de cancha de fútbol y fondo opaco sin ciudad antigua.
- Traducción visible de configuración, jugabilidad, teclado, mandos, pausas y opciones de partido. Se conservaron nombres propios de ligas, equipos y recursos.
- Marcador de TV con fondo marino, banda verde agua, reloj, equipos, goles y EN VIVO.
- Cámara: seguimiento centrado en el balón (\`camera_player_bias\`), menos movimiento aleatorio (\`camera_shake\`) y tres estilos mediante \"camera_mode\": 1 panorámica, 2 aérea, 3 teleobjetivo.
- Corregido el crash al faltar imagen de un escudo/recurso. Si falta una textura, se registra el error sin desreferenciar nulos.
- Eliminada la división por cero si al acabar el partido ambos equipos tienen posesión total cero.
- Conversión de texto UTF-8 a mayúsculas con caracteres sin signo para evitar comportamiento indefinido.
- Indicador de FPS realmente medidos arriba a la derecha durante el partido (\`show_fps\` = true predeterminado).

## Límite de FPS
El motor acepta \"graphics_fps_limit\" con 30, 60 o 120. Limita la velocidad máxima de presentación usando un reloj de alta resolución; **no aumenta mágicamente la potencia de la Lenovo**. Con \"graphics3d_frametime_ms\" = 0 la planificación de render no mantiene un límite entero previo de 33ms.

El perfil \"lenovo_120fps_experimental.config\" reduce a 800x450, 4 muestras SSAO y sombras cada seis cuadros. Probablemente no alcance 120 FPS sostenidos en una Intel HD 400 y la pantalla podría refrescar a 60Hz.

La simulación física sigue con 10ms por paso (100Hz). Aumentar el renderizado no significa 120Hz de física.

## Ejecutar
Desde la carpeta instalada:

\`\`\`bash
./gameplayfootball lenovo_110_15ibr.config
# opcional, mayor carga:
./gameplayfootball lenovo_60fps.config
./gameplayfootball lenovo_120fps_experimental.config
\`\`\`

Configuración > Gráficos permite elegir 30, 60 o 120 y guardar; reiniciar para aplicar. Hacer copia de seguridad de los archivos anteriores y preservar el pack de gráficos 2026/27.

## Verificación pendiente
GitHub Actions confirma compilación C++ únicamente; las pruebas de fidelidad visual, cámara, funcionamiento del menú y FPS reales deben hacerse en la Lenovo. No se garantiza ausencia de todos los bugs.
