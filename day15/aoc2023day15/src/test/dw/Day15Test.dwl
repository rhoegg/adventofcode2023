%dw 2.0
import * from dw::test::Tests
import * from dw::test::Asserts

import * from Day15
---
"Day15" describedBy [
    "hash" describedBy [
        "It should hash HASH" in do {
            hash("HASH") must equalTo(52)
        },
    ],
]
