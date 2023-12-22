/**
* This mapping won't be shared through your library, but you can use it to try out your module and create integration tests.
*/
%dw 2.0
output application/json

import * from Day21
---
load("sample1.txt")
// path finding, starting with go