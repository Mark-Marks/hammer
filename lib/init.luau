--!strict
--!optimize 2
local collect = require("@self/utilities/collect")
local ref = require("@self/utilities/ref")
export type Ref = ref.Identity
local command_buffer = require("@self/utilities/command_buffer")
export type CommandBuffer = command_buffer.Identity
local interval = require("@self/utilities/interval")
local is_a = require("@self/utilities/is_a")
local observers = require("@self/utilities/observers")

return {
    collect = collect,
    ref = ref,
    command_buffer = command_buffer,
    observer = observers.observer,
    monitor = observers.monitor,
    interval = interval,
    is_a = is_a,
}
