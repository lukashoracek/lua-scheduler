local scheduler = require("scheduler")
local sleep = scheduler.sleep

--// Coroutine c1
local c1id = scheduler.resume(coroutine.create(function()
    while sleep(0.4) do
        print("Hello from coroutine 1!")
    end
end))

--// Coroutine c2
scheduler.resume(coroutine.create(function()
    while sleep(0.5) do
        print("Hello from coroutine 2!")
    end
end))

--// Performance printing of coroutine c1
scheduler.resume(coroutine.create(function()
    while sleep(1) do
        local perfData = scheduler.tasks[c1id].performance

        if perfData.calls > 0 then
            print("Coroutine 1 performance\nTotal calls | AVG CPU Time | Total CPU time\n"  ..
                perfData.calls .. "             " ..
                string.format("%.5f", perfData.cpuTimeSpent / perfData.calls * 1000) .. " ms     " ..
                string.format("%.5f", perfData.cpuTimeSpent * 1000) .. " ms")
        end
    end
end))

--// Garbage collection
scheduler.resume(coroutine.create(function()
    while sleep(1) do
        collectgarbage("collect")
    end
end))

while scheduler.run() do end