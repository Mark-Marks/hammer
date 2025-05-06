--!strict
--!native
--!optimize 2
-- pesde adds dependencies by including a folder with them in the package
-- wally just adds a file for each dependency
-- this is here to mitigate that
local jecs = require("./luau_packages/jecs")
export type Archetype = jecs.Archetype
export type Id<T = unknown> = jecs.Id<T>
export type Pair<First, Second> = jecs.Pair<First, Second>
export type Entity<T = unknown> = jecs.Entity<T>
export type World = jecs.World
return jecs
