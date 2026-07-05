--!strict
--!optimize 2

--- Allows for throttling of systems to run every `n` seconds.
--- ```luau
--- local replication_throttle = hammer.interval(1 / 10) -- Run every 100ms
--- local function replication()
---     if not replication_throttle() then
---         return
---     end
---
---     for player, packet in replicator:collect_packets() do
---         ...
---     end
--- end
--- ```
local function interval(n: number)
    local pin: number = nil :: any

    @native
    local function throttle()
        if not pin then
            pin = os.clock()
        end

        local elapsed = os.clock() - pin > n
        if elapsed then
            pin = os.clock()
        end

        return elapsed
    end
    return throttle
end

return interval
