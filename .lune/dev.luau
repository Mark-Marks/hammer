--!strict
local task = require("@lune/task")

local spawn = require("./util/spawn")
local watch = require("./util/watch")

task.spawn(watch, "pesde.toml", function()
    spawn.spawn("pesde install")
end, false)
spawn.start("pesde install")
