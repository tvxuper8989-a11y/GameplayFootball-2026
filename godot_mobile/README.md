# GameplayFootball 3D para Android (Godot 4.7.2)

Esta es una **nueva implementación en Godot**, no una conversión automática del motor original C++/SDL2. Incorpora un campo tridimensional estilizado, 22 jugadores low-poly, pelota con desplazamiento y disparos, equipo controlable, IA elemental, cámara televisiva, marcador, controles táctiles, tácticas y menús en español.

## Abrir proyecto
1. Instalar Godot 4.7.2 estable.
2. Abrir la carpeta `godot_mobile/` con el editor.
3. Presionar F6 o F5 para probar la escena.
4. Exportar `Android` usando los templates oficiales de la **misma versión**.

## Compilar APK en GitHub
El workflow `.github/workflows/godot-android-3d.yml` descarga el editor Godot 4.7.2 y sus plantillas oficiales, valida el proyecto en modo headless y exporta una APK debug.
La APK se publica como artefacto de la ejecución.

## Controles
- Android: joystick virtual izquierdo; botones PASE, REMATE, CAMBIAR y CORRER.
- PC: flechas, S (pase), D (remate), Q (cambiar), E (correr), Esc (pausa).
- Menú: partido rápido, formación 4-3-3 / 4-4-2 / 3-5-2, ajustes de FPS y cámara.
- El juego se ejecuta completamente sin Internet.

## Alcance y limitaciones
Es un **prototipo 3D funcional** con modelos geométricos originales creados por código; **no** usa los modelos, cartas, plantillas oficiales, marcas, retratos o recursos propietarios de EA SPORTS FC Mobile. No incluye multijugador, animación capturada profesional ni precisión de simulación AAA. Los límites de 30/60/120 FPS son objetivos, **no** velocidades garantizadas. Es necesario probar la APK instalada en teléfonos reales.

## Distribución
La APK generada por CI usa firma de depuración y es para instalar y probar. Para distribuir en Play Store se necesita firma de publicación, controles de privacidad y verificaciones adicionales.
