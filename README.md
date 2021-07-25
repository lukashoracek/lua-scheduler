# Lua coroutine scheduler
## How does this work?
Every coroutine has to pause itself using `coroutine.yield` in order for the scheduler to resume another coroutine. Coroutines get resumed if they asked the scheduler to resume them in specified `time` using `scheduler.sleep`. It is possible to monitor each coroutine's performance.

## Example
See example in [example.lua](example.lua)

## License
Copyright (c) 2020-2021 Lukáš Horáček  
[MIT Licensed](LICENSE.txt)