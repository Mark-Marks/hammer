--!strict
--!optimize 2
local collect = require("@self/utilities/collect")
export type SignalLike<T...> = collect.SignalLike<any, T...>
export type VerboseSignalLike<D, T...> = collect.SignalLike<D, T...>

local ref = require("@self/utilities/ref")
export type Ref = ref.Identity

local tracker = require("@self/utilities/tracker")
export type Tracker = tracker.Identity
export type TrackerCommands = tracker.Commands

local command_buffer = require("@self/utilities/command_buffer")
export type CommandBuffer = command_buffer.Identity

return {
    collect = collect,
    ref = ref,
    tracker = tracker,
    command_buffer = command_buffer,
}
