/// Five chambers shared with the browser edition.
function orbita_levels() {
    return [
    {
        name: "El primer paso",
        tip: "Recoge la llave dorada antes de llegar a la puerta.",
        map: [
            "#########",
            "#.......#",
            "#.P...K.#",
            "#..###..#",
            "#.....E.#",
            "#########"
        ]
    },
    {
        name: "Un poco de presión",
        tip: "Empuja la caja hasta el círculo verde. Las cajas se empujan, nunca se arrastran.",
        map: [
            "#########",
            "#.......#",
            "#.PB.T..#",
            "#..###..#",
            "#.K...E.#",
            "#########"
        ]
    },
    {
        name: "Dos a la vez",
        tip: "Todos los interruptores deben tener una caja al mismo tiempo.",
        map: [
            "##########",
            "#........#",
            "#.PB..T..#",
            "#........#",
            "#..B..T..#",
            "#.K....E.#",
            "##########"
        ]
    },
    {
        name: "Cambio de dirección",
        tip: "Busca espacio para ponerte detrás de la caja. Deshacer también recupera la llave.",
        map: [
            "#########",
            "#...K...#",
            "#..T....#",
            "#.......#",
            "#..B.#..#",
            "#.P..#.E#",
            "#.......#",
            "#########"
        ]
    },
    {
        name: "La última cámara",
        tip: "Planea las dos rutas. Si una caja llega a una esquina, puedes deshacer sin límite.",
        map: [
            "###########",
            "#....#....#",
            "#.T..#..T.#",
            "#.........#",
            "#.B.....B.#",
            "#....#....#",
            "#.P.K#..E.#",
            "#.........#",
            "###########"
        ]
    }
];
}
