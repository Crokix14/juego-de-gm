# Órbita: las veinte cámaras del Custodio

Abre `PUZLE IDEA.yyp` en GameMaker (el proyecto registra IDE 2024.14.4.222) y pulsa Ejecutar. El menú permite elegir cualquiera de las 20 cámaras con izquierda/derecha; Enter inicia. Las teclas 1–9 seleccionan las primeras nueve para pruebas rápidas.

## Campaña

- **1–5:** cajas, X, rejas y llaves. Una caja en cada X abre las rejas; al retirar una caja se vuelven a cerrar. La llave permite abrir la puerta.
- **6–14:** aparecen pinchos por ciclos, espinas fijas y vigilantes que persiguen al jugador. Los obstáculos, cajas y rejas bloquean también a los vigilantes.
- **15:** la forja contiene la espada azul. Debes recogerla antes de salir. Se empieza con espada al seleccionar directamente los niveles 16–20.
- **16–19:** combate combinado con trampas y puzles. Los vigilantes necesitan dos golpes.
- **20:** el Custodio tiene 100 puntos de vida, diez patrones y un escudo. Solo recibe un golpe de 10 puntos por periodo de recuperación. Al derrotarlo desaparecen sus vigilantes y deja la llave que abre la salida final.

Tienes cinco puntos de vida. Tras recibir daño dispones de 1,1 segundos de invulnerabilidad. Cada nivel restaura la vida; al morir puedes reiniciar sin perder las mejores marcas. Los pinchos cíclicos están apagados al comienzo, se anuncian en amarillo y se activan en rojo. Las espinas fijas siempre hacen daño. Puedes esperar sin moverte para observar los ciclos.

## Controles

| Tecla | Acción |
| --- | --- |
| Flechas / WASD | Mover por casillas |
| Espacio | Espada: golpe a enemigos en tu casilla o una casilla adyacente; 0,38 segundos entre ataques |
| Z | Deshacer movimiento, caja, llave y recogida de espada |
| R | Reiniciar nivel |
| Escape | Pausa / continuar; desde victoria o muerte, menú |
| M durante pausa | Menú |
| T | Alternar sprites originales y gráficos geométricos |
| Enter desde victoria | Siguiente cámara; tras la final, menú |

Deshacer no restaura vida, enemigos, tiempo ni el daño al jefe. Está desactivado mientras el jefe está vivo y tras morir. Pausar congela trampas, enemigos y ataques. Las mejores marcas se guardan en `orbita_progress.ini` en el sandbox del juego.

## Los diez patrones del jefe

Todos tienen aviso amarillo, ataque rojo y recuperación sin escudo. Cuando le quedan 40 puntos o menos reduce el tiempo de aviso.

1. **Cruz de acero:** fila y columna del jefe.
2. **Anillo interior:** las casillas a dos pasos del jefe.
3. **Columna marcada:** apunta a tu columna al iniciar el aviso.
4. **Fila marcada:** apunta a tu fila al iniciar el aviso.
5. **Barrido izquierdo:** mitad izquierda de la arena.
6. **Barrido derecho:** mitad derecha.
7. **Suelo alterno:** casillas alternas; cambia de casilla para esquivar.
8. **Invocación:** crea vigilantes en dos puntos señalados.
9. **Onda expansiva:** tres anillos sucesivos desde el jefe.
10. **Impacto dirigido:** zona de 3×3 alrededor de tu posición al iniciar el aviso.

El jefe repite el ciclo si no lo derrotas. Busca una casilla segura durante los avisos y aprovecha sus dos segundos de recuperación para acercarte y golpear.

## Desarrollo y validación

`Room1` inicia `Obj_orbita`, que gestiona estado, controles, combate y dibujo GUI. `orbita_levels` contiene los 20 mapas. Leyenda: `#` muro, `P` jugador, `B` caja, `T` X, `G` reja, `K` llave, `E` puerta, `H` pinchos cíclicos, `S` espinas, `N` vigilante, `F` espada y `Q` jefe. Los sprites y objetos originales siguen disponibles. Los actores nuevos se dibujan con formas propias y el tablero ajusta el tamaño de las casillas a cada mapa.

Desde la raíz del repositorio puedes ejecutar `node tests/game-maker-state.cjs`. Comprueba los métodos de estado reales escritos en el subconjunto de GML compatible con JavaScript: rutas de los 19 puzles con enemigos estacionarios, rejas y llaves, deshacer, daño, invulnerabilidad, pausa, muerte, persecución y bloqueo de enemigos, recogida de espada, golpes y recarga, diez patrones distintos con casillas seguras, escudo, invocación, onda expansiva, recuperación, derrota del jefe y salida final.

Estas pruebas no compilan GML ni demuestran que las rutas sean seguras frente a enemigos en movimiento. El entorno de nube no tiene el compilador de GameMaker: quedan pendientes la compilación en tu PC, revisión visual y pruebas de dificultad con encuentros en tiempo real. La versión web de `../browser` conserva sus cinco puzles originales; esta ampliación corresponde a GameMaker.
