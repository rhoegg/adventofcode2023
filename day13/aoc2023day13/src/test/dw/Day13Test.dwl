%dw 2.0
import * from dw::test::Tests
import * from dw::test::Asserts

import * from Day13
---
"Day13" describedBy [
    "part2" describedBy [
        "It should work" in do {
            log({
                part2: part2("sample1.txt") 
            }) must beObject()
        }
    ],
    "transpose" describedBy [
        "It should swap rows for columns" in do {
            transpose(["#.#", "...", ".#."]) must equalTo(["#..", "..#", "#.."])
        },
    ],
    "findHorizontalReflectionPosition" describedBy [
        "It should find the row number where the pattern reflects" in do {
            findHorizontalReflectionPosition([
                "#.#.",
                "...#",
                "...#",
                "#.#.",
                "####"
            ]) must equalTo(2)
        },
        "It should find row 0 for the first sample" in do {
            findHorizontalReflectionPosition([
                "#.##..##.",
                "..#.##.#.",
                "##......#",
                "##......#",
                "..#.##.#.",
                "..##..##.",
                "#.#.##.#."
            ]) must equalTo(0)
        },
        "It should find row 3 for the second sample" in do {
            findHorizontalReflectionPosition([
                "#...##..#",
                "#....#..#",
                "..##..###",
                "#####.##.",
                "#####.##.",
                "..##..###",
                "#....#..#"
            ]) must equalTo(4)
        }
    ],
    "findVerticalReflectionPosition" describedBy [
        "It should find column 5 in the first sample" in do {
            findVerticalReflectionPosition([
                "#.##..##.",
                "..#.##.#.",
                "##......#",
                "##......#",
                "..#.##.#.",
                "..##..##.",
                "#.#.##.#."
            ]) must equalTo(5)
        },
        "It should find column 0 in the second sample" in do {
            findVerticalReflectionPosition([
                "#...##..#",
                "#....#..#",
                "..##..###",
                "#####.##.",
                "#####.##.",
                "..##..###",
                "#....#..#"
            ]) must equalTo(0)
        }
    ],
    "findVerticalReflectionPositionBesides" describedBy [
        "It should find nothing in this one" in do {
            findVerticalReflectionPositionBesides([
                "#.###..#..###",
                ".#...##.####.",
                ".#...##.####.",
                "#.###..#..###",
                "########.##.#",
                ".#..##.#.#..#",
                "..#..#.##.#..",
                "##..##..###.#",
                "######.##..#.",
                "######.##....",
                "##..##..###.#",
                "..#..#.##.#..",
                ".#..##.#.#..#"
            ], 0) must equalTo(0)
        },
    ],
]
