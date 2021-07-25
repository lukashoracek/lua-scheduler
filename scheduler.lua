--// Copyright (c) 2020-2021 Lukáš Horáček
--// MIT Licensed

local coroutine = coroutine
local table = table
local os = os

local scheduler; scheduler = {
    tasks = {}; --// Registered tasks
    lastID = 0; --// Last registered task ID
    runningIDs = {}; --// IDs of running tasks
    sleeping = {}; --// Sleeping task info

    resume = function(c, ...)
        --// Make unique ID for new task
        local id = scheduler.lastID + 1
        scheduler.lastID = id

        --// Register task
        local task = {
            c = c; --// Coroutine
            id = id;
            args = {...};
            start = os.clock();
            performance = {
                calls = 0;
                cpuTimeSpent = 0;
            };
        }
        scheduler.tasks[id] = task

        --// Store time before resuming task to measure performance
        local startTime = os.clock()

        --// Resume task
        table.insert(scheduler.runningIDs, id)

        coroutine.resume(c, ...)

        --// Performance info
        task.performance.calls = 1
        task.performance.cpuTimeSpent = os.clock() - startTime

        return id
    end;

    resumeMeIn = function(sleepTime)
        --// Coroutine which called resumeMeIn should be last in scheduler.runningIDs
        local id = table.remove(scheduler.runningIDs)

        --// Insert task ID into sleeping table
        table.insert(scheduler.sleeping, {wakeupTime = os.clock() + sleepTime; id = id;})

        return id
    end;

    run = function()
        --// All tasks finished
        if #scheduler.sleeping == 0 then
            return false
        end

        --// Sleeping table offset
        local sleepingOffset = 0

        for i=1,#scheduler.sleeping do
            local taskSleepInfo = scheduler.sleeping[i + sleepingOffset]

            --// Check if it's time to wake up the task
            if os.clock() >= taskSleepInfo.wakeupTime then
                local task = scheduler.tasks[taskSleepInfo.id]

                --// Make sure task exists
                if not task then
                    error("Failed to find sleeping task with ID " .. tostring(sleeping.id))
                end

                --// Store time before resuming task to measure performance
                local runStart = os.clock()

                --// Remove task from sleeping table
                table.remove(scheduler.sleeping, i + sleepingOffset)
                sleepingOffset = sleepingOffset - 1

                --// Resume task
                table.insert(scheduler.runningIDs, task.id)
                local success, err = coroutine.resume(task.c, unpack(task.args))

                --// Performance
                local runTook = os.clock() - runStart

                task.performance.calls = task.performance.calls + 1
                task.performance.cpuTimeSpent = task.performance.cpuTimeSpent + runTook

                --// Task error reporting
                if not success then
                    print("Error in coroutine " .. task.id, err)
                end
            end
        end

        return true
    end;

    sleep = function(sleepTime)
        local id = scheduler.resumeMeIn(sleepTime or 0)

        --// Pause task
        --// and save arguments to resume it later with
        local args = coroutine.yield()
        scheduler.tasks[id].args = {args}

        return true
    end;
}

return scheduler