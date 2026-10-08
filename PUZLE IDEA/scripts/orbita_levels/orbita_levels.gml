/// # muro, P jugador, B caja, T X, G reja, K llave, E salida.
/// H pinchos ciclicos, S espinas, N vigilante, F espada, Q jefe.
function orbita_levels() {
    return [
    {
        name: "La caja y la X",
        tip: "Empuja la caja a la X para abrir la reja y alcanzar la llave.",
        map: [
            "###########",
            "#.....#...#",
            "#.PB.T#.K.#",
            "#.....G...#",
            "#.....#...#",
            "#.....#.E.#",
            "###########"
        ]
    },
    {
        name: "Cambio de direccion",
        tip: "Ponte debajo de la caja y empujala hacia la X.",
        map: [
            "###########",
            "#.....#...#",
            "#..T..#.K.#",
            "#.....G...#",
            "#..B..#...#",
            "#.P...#.E.#",
            "#.....#...#",
            "###########"
        ]
    },
    {
        name: "Dos cerraduras",
        tip: "Las dos X deben tener una caja para abrir la reja.",
        map: [
            "###########",
            "#.....#...#",
            "#.B.T.#.K.#",
            "#.P...G...#",
            "#.B.T.#...#",
            "#.....#.E.#",
            "###########"
        ]
    },
    {
        name: "El rodeo",
        tip: "Rodea el muro para empujar la caja desde abajo.",
        map: [
            "###########",
            "#.....#...#",
            "#...T.#.K.#",
            "#.....G...#",
            "#.#.B.#...#",
            "#.#...#...#",
            "#.P...#.E.#",
            "#.....#...#",
            "###########"
        ]
    },
    {
        name: "La ultima reja",
        tip: "Activa ambas X. Puedes deshacer si una caja queda atrapada.",
        map: [
            "###########",
            "#.....#...#",
            "#.T.T.#.K.#",
            "#.....G...#",
            "#.B.B.#...#",
            "#..P..#...#",
            "#.....#.E.#",
            "#.....#...#",
            "###########"
        ]
    },
    {
        name: "Suelo inestable",
        tip: "Los pinchos rojos se activan por ciclos. Espera al color apagado.",
        map: [
            "#############",
            "#......#....#",
            "#..T...#.K..#",
            "#..H...#....#",
            "#......GH...#",
            "#..B...#....#",
            "#.P....#..E.#",
            "#......#....#",
            "#############"
        ]
    },
    {
        name: "Pasillo de espinas",
        tip: "Evita las espinas fijas. No pierdes vida al empujar una caja sobre ellas.",
        map: [
            "#############",
            "#......#....#",
            "#.PB.T.#.K..#",
            "#..##..#....#",
            "#......G....#",
            "#....SS#.S..#",
            "#......#..E.#",
            "#......#....#",
            "#############"
        ]
    },
    {
        name: "El vigilante",
        tip: "El vigilante te persigue. Antes de tener espada, usa los caminos laterales.",
        map: [
            "#############",
            "#......#....#",
            "#.T.T..#.K..#",
            "#......#....#",
            "#......G.N..#",
            "#.B.B..#....#",
            "#..P...#..E.#",
            "#......#....#",
            "#############"
        ]
    },
    {
        name: "Presion doble",
        tip: "Activa las dos X sin quedarte entre el vigilante y las rejas.",
        map: [
            "#############",
            "#......#....#",
            "#.T.T..#.K..#",
            "#......#....#",
            "#.#..N.GH...#",
            "#.B.B..#....#",
            "#..P...#..E.#",
            "#......#....#",
            "#############"
        ]
    },
    {
        name: "Reloj de acero",
        tip: "Observa el ritmo de los pinchos antes de cruzar el pasillo.",
        map: [
            "#############",
            "#......#....#",
            "#..T...#.K..#",
            "#..H...#....#",
            "#..H...GH...#",
            "#..B...#....#",
            "#.P....#..E.#",
            "#......#....#",
            "#############"
        ]
    },
    {
        name: "Patrulla interior",
        tip: "La llave tiene guardian. Atraelo lejos de la salida.",
        map: [
            "#############",
            "#......#....#",
            "#.PB.T.#.K..#",
            "#..##..#.N..#",
            "#....H.G....#",
            "#......#....#",
            "#......#..E.#",
            "#......#....#",
            "#############"
        ]
    },
    {
        name: "La ruta estrecha",
        tip: "Las espinas bloquean el camino corto. Busca un rodeo.",
        map: [
            "#############",
            "#......#....#",
            "#.T.T..#.K..#",
            "#.S.S..#....#",
            "#......G....#",
            "#.B.B..#.S..#",
            "#..P...#..E.#",
            "#......#....#",
            "#############"
        ]
    },
    {
        name: "Dos amenazas",
        tip: "Dos vigilantes. Las cajas pueden cortarles el paso.",
        map: [
            "#############",
            "#......#....#",
            "#....T.#.K..#",
            "#......#....#",
            "#.#..N.G.N..#",
            "#.#..B.#....#",
            "#.P....#..E.#",
            "#......#....#",
            "#############"
        ]
    },
    {
        name: "La antesala",
        tip: "Resuelve las X mientras evitas trampas y un guardian.",
        map: [
            "#############",
            "#......#....#",
            "#..T...#.K..#",
            "#..H...#....#",
            "#....N.GH...#",
            "#..B...#....#",
            "#.P....#..E.#",
            "#......#....#",
            "#############"
        ]
    },
    {
        name: "La forja",
        tip: "Recoge la espada azul. ESPACIO golpea a los enemigos que tengas cerca.",
        map: [
            "#############",
            "#......#....#",
            "#.PB.T.#.K..#",
            "#..##..#....#",
            "#......G.N..#",
            "#......#....#",
            "#...F..#..E.#",
            "#......#....#",
            "#############"
        ]
    },
    {
        name: "Primer duelo",
        tip: "Los guardianes necesitan dos golpes. Espera el tiempo entre ataques.",
        map: [
            "#############",
            "#......#....#",
            "#.T.T..#.K..#",
            "#......#....#",
            "#......G.N..#",
            "#.B.B..#....#",
            "#..P.N.#..E.#",
            "#......#....#",
            "#############"
        ]
    },
    {
        name: "Acero y pinchos",
        tip: "El ataque no te protege de las trampas. Vigila tu vida.",
        map: [
            "#############",
            "#......#....#",
            "#....T.#.K..#",
            "#..H...#....#",
            "#.#....GHN..#",
            "#.#..B.#....#",
            "#.P....#..E.#",
            "#......#....#",
            "#############"
        ]
    },
    {
        name: "Los tres guardianes",
        tip: "Separa a los enemigos antes de luchar. No atraviesan cajas.",
        map: [
            "#############",
            "#......#....#",
            "#..T...#.K..#",
            "#......#.N..#",
            "#....N.G....#",
            "#..B...#..N.#",
            "#.P....#..E.#",
            "#......#....#",
            "#############"
        ]
    },
    {
        name: "Ultima cerradura",
        tip: "Activa ambas X y conserva vida para llegar a la llave.",
        map: [
            "#############",
            "#......#....#",
            "#.T.T..#.K..#",
            "#..##H.#....#",
            "#....N.GHN..#",
            "#.B.B..#....#",
            "#..P...#..E.#",
            "#......#....#",
            "#############"
        ]
    },
    {
        name: "El Custodio",
        tip: "Diez ataques anunciados. Esquiva el rojo, acercate en la recuperacion y golpea con ESPACIO. El jefe suelta la llave.",
        map: [
            "#############",
            "#.....E.....#",
            "#...........#",
            "#...........#",
            "#.....Q.....#",
            "#...........#",
            "#..#.....#..#",
            "#...........#",
            "#..F..P.....#",
            "#...........#",
            "#############"
        ]
    }
];
}
