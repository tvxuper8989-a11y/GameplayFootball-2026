# GameplayFootball 2026/27 — interfaz española, FPS, cámara y marcador TV

## Interfaz
- Home 16:9, botones compactos y textos en español.
- Menús con fondo opaco, sin la antigua ciudad que se veía en las fotografías.
- Configuración, controles, pausa y selección del partido con etiquetas principales traducidas.

## FPS: límites, no promesas
- Limites de render: 30, 60 o 120 FPS, en Configuración > Gráficos. Reiniciar después de cambiar.
- Limitador con reloj monotónico y espera de alta resolución: \"graphics_fps_limit\".
- Física a 100 Hz; un render de 120 FPS no supone física a 120 Hz.
- Los FPS reales pueden ser inferiores al límite, sobre todo en Lenovo IdeaPad 110-15IBR (Celeron/Intel HD integrada).
- La pantalla podría estar limitada a 60 Hz. Los 120 cuadros no serían 120 imágenes distintas visibles a 60 Hz.
- Indicador de FPS durante el partido, aproximado a partir del tiempo de presentación de los últimos cuadros.

## Configuraciones disponibles
- `lenovo_110_15ibr.config`: 960 × 540, máximo solicitado 30 FPS.
- `lenovo_60fps.config`: 960 × 540, máximo solicitado 60 FPS.
- `lenovo_120fps_experimental.config`: 800 × 450, límite solicitado 120 FPS, oclusión y sombras aligeradas.

Ejecutar desde la carpeta del juego:

```bash
./gameplayfootball lenovo_110_15ibr.config
# Alternativas que demandan mayor rendimiento:
./gameplayfootball lenovo_60fps.config
./gameplayfootball lenovo_120fps_experimental.config
```

## Marcador y cámara
- Barra televisiva con nombres de equipos, logos cuando existan, reloj, goles y la etiqueta EN VIVO.
- `camera_player_bias`: menor valor significa que la cámara prioriza más al balón; predeterminado 0.38.
- `camera_shake`: controla los temblores aleatorios (0.02 en el perfil Lenovo).
- `camera_mode`: 1 panorámica, 2 aérea, 3 teleobjetivo.

## Correcciones
- Carga de imagen faltante sin desreferenciar puntero nulo.
- Cálculo del porcentaje de posesión sin dividir por cero.
- Conversión a mayúsculas usando bytes sin signo para evitar comportamiento indefinido.

## Alcance de las pruebas
La compilación de Linux CI valida sintaxis y enlazado, **no** mide FPS en la Lenovo ni garantiza que todo esté libre de bugs. Se debe probar visualmente el menú, la cámara y el marcador en el equipo real.
