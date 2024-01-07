%dw 2.0
output application/json

import * from Day25
---
shortestPath(loadComponents("puzzle-input.txt"), "dtl", "hxz")