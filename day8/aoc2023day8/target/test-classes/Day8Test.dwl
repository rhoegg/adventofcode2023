/**
* This mapping won't be shared through your library, but you can use it to try out your module and create integration tests.
*/
%dw 2.0
output application/json

import * from Day8

var maps = parseMaps("sample1.txt")
---
stepsFrom(maps, "AAA")