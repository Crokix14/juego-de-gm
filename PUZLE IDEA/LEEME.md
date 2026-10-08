# Órbita para GameMaker

Abre `PUZLE IDEA.yyp` en GameMaker (el proyecto registra IDE 2024.14.4.222) y pulsa Ejecutar. En el menú elige cámara con 1–5 o izquierda/derecha y pulsa Enter.

El juego tiene cinco cámaras: recoge la llave, empuja una caja sobre cada interruptor y alcanza la puerta. Usa flechas o WASD. Z deshace, R reinicia, Escape pausa, y T alterna entre los sprites originales y gráficos geométricos. Desde pausa, M abre el menú. Las mejores marcas se guardan en `orbita_progress.ini` dentro del sandbox del juego.

`Room1` inicia `Obj_orbita`, que gestiona estado, controles y dibujo GUI. `orbita_levels` contiene los mapas (`#` muro, `P` jugador, `B` caja, `T` interruptor, `K` llave, `E` puerta). Los objetos y sprites originales siguen disponibles; el nuevo tablero usa movimiento por casillas y no depende de las máscaras de colisión de los sprites.

Las cinco distribuciones coinciden con las de la versión web y tienen solución comprobada. La compilación y ejecución de GML requieren GameMaker y deben comprobarse en tu PC: este entorno no incluye su compilador. Verifica menú, movimiento, empujar contra muros/cajas, recoger llave, salida bloqueada, victoria, cambio de cámara, deshacer después de recoger la llave o ganar, reinicio, pausa y persistencia de marcas al cerrar y reabrir.
