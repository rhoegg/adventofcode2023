%dw 2.0
import * from dw::test::Tests
import * from dw::test::Asserts

import * from Day14
---
"Day14" describedBy [
    "tiltRow" describedBy [
        "It should leave a single round rock" in do {
            tiltRow(["O"]) must equalTo(["O"])
        },
        "It should leave a single cube rock" in do {
            tiltRow(["#"]) must equalTo(["#"])
        },
        "It should leave a single empty" in do {
            tiltRow(["."]) must equalTo(["."])
        },
        "It should leave two round rocks" in do {
            tiltRow(["O", "O"]) must equalTo(["O", "O"])
        },
        "It should slide one round rock after one empty" in do {
            tiltRow([".", "O"]) must equalTo(["O", "."])
        }
        // ,
        // "It should slide one round rock after many empty" in do {
        //     tiltRow(".......O" splitBy "") must equalTo("O......." splitBy "")
        // }
    ],
]
