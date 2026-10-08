/// G = reja; T = X activada por una caja.
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
    }
];
}
