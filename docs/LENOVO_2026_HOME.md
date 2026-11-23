# GameplayFootball 2026/27 - Home y perfil Lenovo IdeaPad 110-15IBR

## Cambios de esta version
- Home renovado: reemplaza el menu original con paneles procedimentales, titulos de temporada, navegacion de teclado y solo opciones funcionales (Jugar partido, Configuracion, Creditos, Salir).
- Se abre el Home directamente, sin pasar por la pantalla de introduccion de 2015.
- Incluye los controles arreglados anteriormente: flechas, Enter, Enter numerico y Espacio.
- Perfil **opcional** para Intel HD Graphics / 4 GB RAM en `data/lenovo_110_15ibr.config`. No modifica el perfil original.
- Reducida la carga grafica de 1280x720 a 960x540, con intervalo objetivo de 33 ms (aproximadamente 30 FPS; no garantizados).
- El shader de oclusion ambiental usa 8 muestras en vez de 32 con el perfil Lenovo (32 en el original). G-buffer RGBA8 para albedo y auxiliar, conservando normales HDR para evitar distorsiones.
- Sombras actualizadas cada 4 cuadros en vez de cada 2; camara del menu sin ruido animado.
- Cambios de jugador mas agiles, disparos/pases largos con un umbral de espera menor y buffer de acciones reducido.
- Jugadores de la IA reaccionan hasta 10 ms antes. Los parametros se pueden revertir editando el .config.

## Ejecutar desde la carpeta del juego
1. Descargar **Artifacts > gameplayfootball-2026-linux** en la ultima ejecucion verde de GitHub Actions y extraer el ZIP.
2. Conservar copia del ejecutable anterior y de los recursos actuales (incluido el pack grafico 2026/27).
3. Copiar el nuevo ejecutable y el nuevo archivo `lenovo_110_15ibr.config` (incluido en el ZIP) dentro de `~/Juegos/GameplayFootball2026/`.
4. En la terminal:

```bash
cd ~/Juegos/GameplayFootball2026
chmod +x ./gameplayfootball
./gameplayfootball lenovo_110_15ibr.config
```

### Con pack grafico adicional
Copiar a este perfil las lineas `ball_object`, `boot_texture`, `stadium_object` y `scoreboard_background` del archivo `football_graficos_2026_27.config` generado por el pack, si se desea mantener esa seleccion. Los recursos del pack pueden permanecer instalados.

### Ajustes progresivos de calidad
Si 960x540 va muy lento, probar 800x450; si va fluido, 1280x720. Cambiar la linea `"graphics_ssao_samples" "8"` a 4 para reducir aun mas el trabajo del shader, o a 16 para mejor calidad. `graphics_shadow_update_frames` admite 1 a 8; valores altos reducen las actualizaciones y pueden hacer visibles sombras atrasadas.

Si hay fallos visuales, quitar `"graphics_low_memory" "true"` o cambiarlo por `false` para recuperar buffers originales; si se desea el manejo de control original, eliminar las lineas `human_*` y `ai_reaction_bonus_ms`.

**Limites:** no agrega animaciones 3D ni acciones imposibles sin nuevos datos de animacion; los parametros cambian respuesta de comandos y percepcion IA. No hay benchmarks reales en una Lenovo 110-15IBR todavia. La compilacion de GitHub no certifica rendimiento ni calidad visual en ese equipo.
