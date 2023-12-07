%dw 2.0
import * from dw::test::Tests
import * from dw::test::Asserts

import * from Solution
---
"Solution" describedBy [
    "winningRange" describedBy [
        "It should do something" in do {
            winningRange(???) must beObject()
        },
    ],
]
