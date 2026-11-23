# GameplayFootball 2026/27: primer avance

Repositorio fuente: https://github.com/vi3itor/GameplayFootball

La version 2026 sigue en desarrollo. Se conserva LICENSE y la atribucion original.
Las marcas, camisetas, nombres y logos pueden estar sujetos a derechos independientes.

## Actualizaciones ya incorporadas

1. El ejecutable admite la opcion opcional database_filename en football.config.
2. El script scripts/temporada_2026.py crea una base de temporada separada.
3. El script admite CSV de equipos y jugadores EXISTENTES, comprueba IDs y valores,
   prueba la integridad SQLite y nunca toca la base antigua.
4. Crea el perfil data/football_2026.config: 1280x720, modo ventana,
   render deseado 33 ms y simulacion 10 ms. No garantiza 30 FPS.

## Crear el pack de temporada

Desde la raiz del repositorio:

    python scripts/temporada_2026.py --root . --teams plantillas/equipos_2026.csv --players plantillas/jugadores_2026.csv

Sin --apply no modifica nada. Tras cargar CSV con datos verificados:

    python scripts/temporada_2026.py --root . --teams plantillas/equipos_2026.csv --players plantillas/jugadores_2026.csv --apply

Los CSV de ejemplo solo tienen encabezados, intencionadamente: todavia no
se verificaron fichajes de 2026/27. Si no ingresas jugadores, se conservan
los antiguos. No se crean clubes ni campeonatos nuevos en esta fase.

Genera:
- data/databases/default/database_2026.sqlite
- data/football_2026.config

Nunca sobrescribe esos archivos si ya existen.

## Ejecutar

Compilar conforme a README.md. Para Windows, la rama windows es el punto de
partida del proyecto original, y aun requiere pruebas. Copiar data/. en el
directorio de ejecucion (por ejemplo build/Release o build/).

Arrancar desde ese directorio:

    gameplayfootball.exe football_2026.config

Para Linux:

    ./gameplayfootball football_2026.config

Sin argumento se utiliza la configuracion original football.config.

## Verificacion

    python -m unittest discover -s tests_2026 -v

Estas pruebas verifican la herramienta Python, no demuestran que el motor C++
compile ni que funcione en Windows. Pendientes: datos oficiales 2026/27,
nuevas competiciones, modos Liga/Copa/Editor, grafica, jugabilidad y .exe.
