--!strict
local process = require("@lune/process")
local task = require("@lune/task")

--- Start a process with the given command and options
--- ```luau
--- spawn.start("lune run test")
--- ```
--- @param cmd string
--- @param options process.SpawnOptions?
--- @return process.SpawnResult
local function start_process(cmd: string, options: process.ExecOptions?): process.ExecResult
    local arguments = string.split(cmd, " ")
    local command = arguments[1]
    table.remove(arguments, 1)

    local opts: process.ExecOptions = options ~= nil and options or {}
    opts.stdio = opts.stdio ~= nil and opts.stdio or "forward" :: any

    return process.exec(command, arguments, opts)
end

--- `task.spawn` a process with the given command and options
--- ```luau
--- spawn.spawn("lune run test") -- process now runs in the background!
--- ```
--- @param cmd string
--- @param options process.SpawnOptions?
--- @return process.SpawnResult
local function spawn_process(cmd: string, options: process.ExecOptions?)
    task.spawn(start_process, cmd, options)
end

local spawn = {
    start = start_process,
    spawn = spawn_process,
}

return spawn
