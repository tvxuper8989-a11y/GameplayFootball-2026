# GameplayFootball 2026/27 — Paquete gráfico (versión de conceptos)

## Qué es este paquete
Se investigaron lanzamientos de pelotas y botines, así como equipaciones de la temporada.
**Los PNG creados son diseños originales ilustrativos, NO reproducciones oficiales.**
No se distribuyen fotografías comerciales, logos, marcas registradas, rostros de futbolistas
ni texturas de terceros sin permiso.

Fuentes consultadas: archivo catalogo_verificado_2026.json de esta carpeta.

## Cómo generar el ZIP de recursos
Desde la raíz del repositorio con Python >=3.10:

    pip install pillow==11.3.0
    python scripts/generar_graficos_2026.py --source data --output build_assets_2026_27

Se crea una estructura lista para superponer en la carpeta de ejecución del juego:
- Pelotas: modelos .object y .ase derivados del modelo original, y textura PNG nueva.
- Botines: 9 texturas conceptuales de las líneas Nike, adidas, PUMA.
- Kits: para cada club del repositorio, home / away / third / fourth / GK en PNG.
- Marcadores: 3 fondos alternativos PNG.
- Hair: 5 colores nuevos, usando mallas de pelo originales.
- Face: 4 retratos genéricos para pruebas editoriales (NO conectados a modelos 3D).
- Stadiums: escenario 3D original intacto; nueva pantalla introductoria y vallas.
- Configuración: football_graficos_2026_27.config.

El script no cambia los recursos de data/. Conservar una copia del directorio
de ejecución antes de instalar el overlay, porque la instalación copiará por
encima de algunos archivos existentes de kits, pelo e intro.

## Instalación y selección
1. Descargar el ZIP desde GitHub Actions, flujo "Crear pack grafico 2026-27".
2. Extraer el ZIP y copiar su contenido dentro del directorio de ejecución
   en el que existen media/, databases/ y gameplayfootball (o gameplayfootball.exe).
3. Compilar el motor a partir de la rama master, que debe contener los cambios
   de soporte a ball_object, boot_texture, stadium_object, scoreboard_background.
4. Ejecutar:
       gameplayfootball.exe football_graficos_2026_27.config

Para cambiar pelota/scoreboard/botines globales editar los valores correspondientes
en ese archivo. Las opciones Kit 03 y Kit 04 aparecen en el selector visual tras
compilar las modificaciones del menú.

**Limitaciones:** no incluye caras personalizadas ni peinados 3D nuevos,
no crea estadios 3D nuevos, no hay asignación de botas por jugador ni
scoreboards auténticos de ligas. Los kits son esquemas artísticos que
respetan el formato UV/alpha original; su aspecto en el juego requiere
validación visual. No garantiza buen rendimiento sin pruebas reales.

## Fuentes deportivas verificadas
- Premier League/PUMA: pelota STELLAR NITRO ULTIMATE 26/27.
- Nike: pelota Control (competencias femeninas) y líneas Mercurial,
  Phantom y Tiempo.
- adidas: F50, Predator y Copa.
- PUMA: Future, Ultra y King.
- Real Madrid: camiseta local 26/27 confirmada por el club.
- Barcelona: camiseta local 26/27 confirmada por su tienda oficial.

Nike será proveedor de balón de competiciones masculinas de la UEFA
desde **2027/28**, no desde 2026/27.
