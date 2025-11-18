<p align="center">
    <img src="assets/hammer-logo.png">
</p>

[![CI](https://img.shields.io/github/actions/workflow/status/mark-marks/hammer/ci.yml?style=for-the-badge&label=CI)](https://github.com/mark-marks/hammer/actions/workflows/ci.yml)
[![CI](https://img.shields.io/github/actions/workflow/status/mark-marks/hammer/release.yml?style=for-the-badge&label=CD)](https://github.com/mark-marks/hammer/actions/workflows/release.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge)](https://github.com/Mark-Marks/hammer/blob/main/LICENSE)
<a href="https://wally.run/package/mark-marks/hammer"><img alt="Wally" src="https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fmark-marks%2Fhammer%2Frefs%2Fheads%2Fmain%2Fwally.toml&query=package.version&prefix=mark-marks%2Fhammer%40&style=for-the-badge&label=Wally&color=ad4646&logo=data:image/svg%2bxml;base64,PHN2ZyByb2xlPSJpbWciIHZpZXdCb3g9IjAgMCAyNCAyNCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48dGl0bGU+V2FsbHk8L3RpdGxlPjxwYXRoIGZpbGw9Im5vbmUiIGQ9Ik0yMC4zMjUgMTguMTkxYy0xLjkxNSAyLjU5OS01LjEyNyA0LjI1NC04LjM1OCA0LjE4MS0uMjk2LS41MjgtLjc2My0xLjY3My4zNDgtMS4yOTcgMi4zNTUtLjA3NiA0Ljc3LTEuMDE0IDYuMzc1LTIuNzYxLjI5OS0uODUzLjgyLS45ODcgMS4zOC0uMzAxbC4xMjcuMDkuMTI4LjA4OHpNMTIuNzg1IDYuMmMtLjg5Mi4yNjQtLjEwNCAyLjY2LjQ1OSAxLjI3Mi0uMDc1LS40MDcuMjItMS4yODgtLjQ1OC0xLjI3MnptLS41OS0uMjQyYy0uNjY0LTEuMzM1IDEuOTY2LS4zNTMgMS44ODItLjIyOC0uMzI2LS44NTYtMi4zMDItMS4yNC0yLjI2My0uMTA4bC4xNzMuMTk3ek0xMS41NCAxOS4zOGMtLjI4LTEuMzY0IDEuOTY1LS45NTggMS45My0xLjgwMS0uOTkyLS4xNi0yLjM4Mi0uODMyLTEuMzQtMS45NjMgMS4wMjctMS4wMjIgMi41MzMtMS45NTYgMi40OTItMy42NDktLjI4NS42MTItLjkyIDEuOTMtMS44MzUgMi4zODctMS41NzMgMS4wOC00LjA5IDEuMTc5LTUuMjYtLjU1LS4zNDktLjQ2My0uNjg3LTEuNDkxLS40NC0uMzQyLjQ2Ni42NjguNiAxLjcwMi0uNTYxIDEuNDUzLTEuMjQ1LS40NDEtLjM2Mi0xLjc2NC0uNC0yLjY0Ni0uNi0xLjE0NCAxLjM3Ni0uNjA4IDEuNjIzLTEuNjk0QzguNjQgOS40MyA2LjcyIDguODMgNS44NDggOC45MWMtLjk5Ni4xNjUuODUxLS40OTUgMS4xOC0uNzkuNzczLS40NTMgMS41MDYtLjk5NiAyLjA5LTEuNjgyLS41NjIuNDgyLS43NjEuNTE2LS43NDktLjI4LTEuMTUyLS41Ny0uMTM3IDEuNjkzLTEuMzk3IDEuNjY4LS45MTIuNjA1LjYxOS0xLjE0NC4yMzItMS43ODctLjIxOS0xLjIzNCAxLjUtMS4zMjIgMS40My0uMjMuNzYyLS42MjQtLjYxNi0xLjAyMy0uNjE2LTEuMTczIDEuMzQ3LTEuMzA3IDMuNDEzLTEuMzk1IDUuMTItLjg3My45MTYuMjUgMS43MDQuODYyIDIuMDA2IDEuNzg2Ljg5NCAyLjA2NC40NzMgNC4zNTEuMjc4IDYuNTA0LS4xOCAxLjExNi40OTMgMi4wNzcgMS4zODEgMi40NjYuNDI2LjkxNyAxLjkxIDEuNzUyLjU3NSAyLjYwOC0xLjUzOSAxLjQ4OC0zLjY2MyAyLjQ3Ny01LjgzOCAyLjI1MnptOS4xMjMtMS42NjVjLTEuMjctLjQ3MS0xLjc3My0xLjc0Mi0yLjg4NC0yLjM2NS0uNTMzLS42MzgtLjk2LTEuMTU0LS4yOS0xLjc4My4yOTktMS4zNjggMS43OC0xLjg1MiAyLjQ1NC0yLjk4Ljc4Ny0uOTY4LjcwNC0yLjQzMS0uMjAyLTMuMjkxLS43OTctLjg2LTIuMDc2LTEuMjA2LTIuNTI3LTIuMzg1LTEuMjMtMS4wMi0zLjAyMS0xLjA1NS00LjQ5OS0xLjY3NS0xLjMyOC0uMTk0LTIuOTA1LS4yNjEtNC4wMjEuNjA2LTEuNDkyLjAzLTEuODA3IDEuNzc3LTIuNTk0IDIuNzI2LS43My42NDktMS42NTMgMS4yNjYtMS4xNTMgMi4zMzQtMS4wNDguNzE3LjE3OCAyLjAzNi42OTIgMi43NTQuMzA3IDEuMjAyLS45OTQgMy4xNzYuOTY4IDMuNTM4Ljc4NC4wMjYgMS4xNzMtLjg2OCAxLjc5Ni0uMDQzIDEuMzc1LjIyNSAxLjA5IDEuODk4IDEuMDE4IDIuOTM2LjA4Mi45MDItMS4wMiAxLjU2NS0uMzI5IDIuNS0uMTQuODc4LS4zMDMgMS42Ni0xLjI3Ni45MjMtMy45OTktMS43MTgtNi42NDktNi4xMy02LjE2Ny0xMC40NzMuMzM0LTQuMTIyIDMuMzc3LTcuODM0IDcuMzQ1LTguOTg4IDQuMDgtMS4zMSA4Ljg0Ny4yODggMTEuMzUzIDMuNzU1IDIuNTg0IDMuNDAxIDIuNzMxIDguMzguMzE2IDExLjkxWk0xMS43NjguMDAzQzYuODQ4LjAzOSAyLjE4NSAzLjQ0NS42NTIgOC4xMmMtMS40OTUgNC4xOC0uMzU4IDkuMTEzIDIuNzc2IDEyLjI0OSAzLjI1NiAzLjQ0IDguNjMzIDQuNTY5IDEzLjAxIDIuNzc0IDQuNjM2LTEuNzg5IDcuODMtNi42OTIgNy41NDItMTEuNjYtLjE1NS00LjY2My0zLjMtOS4wNC03LjY3MS0xMC42NzJhMTEuODcyIDExLjg3MiAwIDAgMC00LjU0LS44MVoiIHN0eWxlPSJmaWxsOiNGRkY7ZmlsbC1vcGFjaXR5OjE7c3Ryb2tlOm5vbmUiLz48L3N2Zz4=" /></a>
<a href="https://pesde.dev/packages/marked/hammer"><img alt="Pesde" src="https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fmark-marks%2Fhammer%2Frefs%2Fheads%2Fmain%2Fpesde.toml&query=version&prefix=marked%2Fhammer%40&style=for-the-badge&label=pesde&color=F19D1E&logo=data:image/svg%2bxml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMTAwIDEwMCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik00OS42MDI1IDBMOTIuOTAzOCAyNVY3NUw0OS42MDI1IDEwMEw2LjMwMTI3IDc1VjI1TDQ5LjYwMjUgMFpNMTQuMzAxMyAyOS42MTg4TDQ5LjYwMjUgOS4yMzc2TDg0LjkwMzggMjkuNjE4OFY3MC4zODEyTDQ5LjYwMjUgOTAuNzYyNEwzMy42MTQ4IDgxLjUzMTlWNjcuMzg0OEMzNC41MTY3IDY4LjUwNzEgMzUuNjM4OCA2OS40MjE1IDM2Ljk4MSA3MC4xMjc5QzM4Ljk3MDEgNzEuMTQ4IDQxLjAzNTcgNzEuNjU4IDQzLjE3NzkgNzEuNjU4QzQ2LjQ0MiA3MS42NTggNDkuMTQ1MiA3MC44OTI5IDUxLjI4NzMgNjkuMzYyOUM1My40ODA1IDY3Ljc4MTggNTUuMTEyNiA2NS43NjcyIDU2LjE4MzYgNjMuMzE5QzU3LjA5MTUgNjEuMzM4MiA1Ny42MzIgNTkuMjc0IDU3LjgwNTQgNTcuMTI2M0M1OS44NzIzIDU3Ljc0NTcgNjIuMjE1NyA1OC4wNTU0IDY0LjgzNTYgNTguMDU1NEM2Ny42OTE4IDU4LjA1NTQgNzAuMzY5NSA1Ny42NDczIDcyLjg2ODYgNTYuODMxM0M3NS4zNjc4IDU1Ljk2NDIgNzcuNDA3OSA1NC44MTY3IDc4Ljk4OSA1My4zODg2TDc1Ljc3NTggNDcuODAzOEM3NC41NTE3IDQ4LjkyNTggNzIuOTk2MSA0OS44NDM5IDcxLjEwOSA1MC41NTc5QzY5LjIyMTkgNTEuMjIxIDY3LjIwNzMgNTEuNTUyNSA2NS4wNjUyIDUxLjU1MjVDNjEuMzkyOSA1MS41NTI1IDU4LjY2NDMgNTAuNjg1NCA1Ni44NzkyIDQ4Ljk1MTNDNTYuNzE5NSA0OC43OTYyIDU2LjU2NyA0OC42MzY1IDU2LjQyMTcgNDguNDcyQzU1LjYxMDIgNDcuNTUzOSA1NS4wMjExIDQ2LjQ4OTYgNTQuNjU0NiA0NS4yNzkxTDU0LjY0NDMgNDUuMjQ1Mkw1NC42NjkgNDUuMjc5MUg3OS4yMTg1VjQxLjk4OTRDNzkuMjE4NSAzOS4wMzEzIDc4LjU1NTUgMzYuMzUzNiA3Ny4yMjk0IDMzLjk1NjVDNzUuOTU0MyAzMS41NTkzIDc0LjA5MjcgMjkuNjQ2NyA3MS42NDQ1IDI4LjIxODZDNjkuMjQ3NCAyNi43Mzk1IDY2LjM2NTcgMjYgNjIuOTk5NSAyNkM1OS42ODQzIDI2IDU2LjgwMjcgMjYuNzM5NSA1NC4zNTQ1IDI4LjIxODZDNTEuOTA2NCAyOS42NDY3IDUwLjAxOTMgMzEuNTU5MyA0OC42OTMyIDMzLjk1NjVDNDcuNjc0MyAzNS43OTgzIDQ3LjA0NjkgMzcuODA1NyA0Ni44MTA4IDM5Ljk3ODhDNDUuNjg4OCAzOS43MjggNDQuNDc3OCAzOS42MDI2IDQzLjE3NzkgMzkuNjAyNkM0MS4wMzU3IDM5LjYwMjYgMzguOTcwMSA0MC4xMTI3IDM2Ljk4MSA0MS4xMzI3QzM1LjMxNjIgNDEuOTY1MSAzMy45OTAyIDQzLjE1NDkgMzMuMDAyOCA0NC43MDIzVjQwLjM2NzdIMjAuNjg1NVY0Ni4yNTg1SDI1LjgxMTNWNzcuMDI2NkwxNC4zMDEzIDcwLjM4MTJWMjkuNjE4OFpNNTUuMTk2MSAzNi4wOTg2QzU0LjY1MjggMzcuMTAxNSA1NC4zMzIxIDM4LjEyMTYgNTQuMjM0IDM5LjE1ODhINzEuNzk3NkM3MS43OTc2IDM4LjAzNjcgNzEuNDQwNSAzNi45NDAxIDcwLjcyNjUgMzUuODY5MUM3MC4wNjM0IDM0Ljc0NyA2OS4wNjg5IDMzLjgwMzUgNjcuNzQyOCAzMy4wMzg0QzY2LjQ2NzcgMzIuMjczNCA2NC44ODY3IDMxLjg5MDggNjIuOTk5NSAzMS44OTA4QzYxLjExMjQgMzEuODkwOCA1OS41MDU4IDMyLjI5ODkgNTguMTc5OCAzMy4xMTQ5QzU2LjkwNDcgMzMuODggNTUuOTEwMSAzNC44NzQ1IDU1LjE5NjEgMzYuMDk4NlpNNDkuNjQ1MSA1MS41NjkyQzQ5LjMwNzYgNTAuNjY0MSA0OC44MzgxIDQ5Ljg3MSA0OC4yMzY3IDQ5LjE4OThDNDguMDg4NSA0OS4wMjE5IDQ3LjkzMjMgNDguODYwOSA0Ny43NjgxIDQ4LjcwNjdDNDYuMDg1IDQ3LjA3NDYgNDQuMDQ0OSA0Ni4yNTg1IDQxLjY0NzggNDYuMjU4NUM0MC4xMTc3IDQ2LjI1ODUgMzguNjEzMSA0Ni41NjQ1IDM3LjEzNCA0Ny4xNzY2QzM1Ljg1OTQgNDcuNjc3MyAzNC42ODYzIDQ4LjU0MzggMzMuNjE0OCA0OS43NzU5VjYxLjQ3QzM0LjY4NjMgNjIuNjY2NCAzNS44NTk0IDYzLjUzNzggMzcuMTM0IDY0LjA4NEMzOC42MTMxIDY0LjY5NjEgNDAuMTE3NyA2NS4wMDIxIDQxLjY0NzggNjUuMDAyMUM0NC4wNDQ5IDY1LjAwMjEgNDYuMDg1IDY0LjE4NjEgNDcuNzY4MSA2Mi41NTRDNDkuNDUxMiA2MC45MjE5IDUwLjI5MjggNTguNjAxMiA1MC4yOTI4IDU1LjU5MjFDNTAuMjkyOCA1NC4wNjc5IDUwLjA3NjkgNTIuNzI3IDQ5LjY0NTEgNTEuNTY5MloiIGZpbGw9IiNGRkZGRkYiPjwvcGF0aD4KPC9zdmc+" /></a>

A set of utilities for [Jecs](https://github.com/ukendio/jecs)
<br/>

</div>

## ⛓️‍💥 Installation

Hammer is available on pesde @ `marked/hammer` and Wally @ `mark-marks/hammer`.

## 📄 Changelog

To view per-version changes, see [the changelog](/CHANGELOG.md).

## 🔨 Usage

All utilities that require a Jecs world to function are exposed via a constructor pattern.\
For instance, to build a `ref`:
```luau
local ref = hammer.ref(world)
```
This is the easiest solution for passing a world that doesn't sacrifice readability internally and externally or bind the developer to a Jecs version that hammer is currently using.

A recommended approach to initialize the utilities which need a world is to place them in a shared ECS `std` folder, which's utilities you can use later:
```luau
-- std/ref.luau
local world = require("./world")
return hammer.ref(world)
```
```luau
-- my_system.luau
local ref = require("@std/ref")
...
```
Initializing them in every file on require shouldn't be a problem, though, as all of them are cached by world (spare for command buffers!).

### Collect

[Collect](/lib/utilities/collect.luau) collects all arguments fired through the given signal into a queue, and exposes an iterator to flush it.\
Its purpose is to interface with signals in ECS code, which ideally should run every frame in a loop.

For instance, take Roblox's RemoteEvents:
```luau
local pings = hammer.collect(events.ping.OnServerEvent)
local function system()
    for _, player, ping in pings do
        events.ping:FireClient(player, "pong!")
    end
end
```

Collect works with any signal which:
- Is a function which sets a callback
- Exposes a `:connect` or `:Connect` method

Collect also returns a cleanup function to stop listening to the event.\
If the signal doesn't return an object with a `:disconnect`, `:Disconnect`, `:destroy`, `:Destroy` method or a cleanup function, it's simply a no-op.

### Command Buffer

A [command buffer](/lib/utilities/command_buffer.luau) lets you buffer world commands in order to prevent iterator invalidation.\
Iterator invalidation refers to an iterator (e.g. `world:query(Component)`) becoming unusable due to changes in the underlying data.

To prevent this, command buffers can be used to delay world operations to the end of the current frame:
```luau
local command_buffer = hammer.command_buffer(world)

while true do
    step_systems()
    command_buffer.flush()
end

-- Inside a system:
command_buffer.add(entity, component) -- This runs after all of the systems run; no data changes while things are running
```

### Ref

A [ref](/lib/utilities/ref.luau) allows for storing and getting entities via some form of reference.\
This is particularly useful for situations where you reconcile entities into your world from a foreign place, e.g. from across a networking boundary, or need an easy way to get an entity from an object, e.g. a player.
```luau
local ref = hammer.ref(world)

for id in net.new_entities.iter() do
    local entity = ref(`foreign-{id}`) -- A new entity that can be tracked via a foreign id
end
```

Refs by default create a new entity if the given value doesn't reference any stored one. In case you want to see if a reference exists, you can find one:
```luau
local entity[: Entity?] = ref.find(`my-key`)
```

Refs can also be deleted:
```luau
local entity = ref(`my-key`)
ref.delete(`my-key`) -- `entity` still persists in the world, but `my-key` doesn't refer to it anymore.
```

Refs are automatically cached by world. `ref(world)` will have the same underlying references as `ref(world)`.\
In case you need an unique reference store, you can omit the cache via `ref(world, true)`.

### Observers

[Observers](/lib/utilities/observers.luau) allow for observing entities of a matching query.

Observers can be seen as a reactive counterpart to systems, similar to hooks, albeit allowing for more flexibility, as they operate on queries in place of singular components.
```luau
hammer.observer(world:query(Position, Velocity), function(entity)
    --- Ran whenever an entity matching the query has any of its terms changed.
    --- In this instance, the callback would be ran whenever an entity which has a position and velocity has either of the two modified.
end)
```

Monitors are a special kind of observer, which run whenever an entity starts or stops matching a query.
```luau
local monitor = hammer.monitor(world:query(Position, Velocity))
monitor.added(function(entity)
    --- Ran whenever an entity starts matching the query.
    --- In this case, the entity began to have both a position and velocity.
end)
monitor.removed(function(entity)
    --- Ran whenever an entity stops matching the query.
    --- In this case, the entity stopped having either a position or a velocity.
end)
```

Both kinds of observers return tables which contain a disconnect function serving as a way to clean the observer up.
```luau
local observer = hammer.observer(...)
observer.disconnect()
```

Remember to be careful! Observers aren't without their costs.

The [Flecs article on observers](https://www.flecs.dev/flecs/md_docs_2ObserversManual.html) contains more useful information about them, albeit the Jecs and Flecs implementations and interfaces don't fully match.

Observers are a direct copy of [the addon in the Jecs repo](https://github.com/Ukendio/jecs/blob/main/addons/ob.luau), licensed under MIT.

### Interval

[Intervals](/lib/utilities/interval.luau) allow for throttling systems to only run every `n` seconds. This can, for instance, be useful to throttle networking events, or physics.

```luau
local replication_throttle = hammer.interval(1 / 10) -- Run every 100ms
local function replication()
    if not replication_throttle() then
        return
    end
    -- Only runs every 100ms

    for player, packet in replicator:collect_packets() do
        ...
    end
end
```

### IsA

[IsA](/lib/utilities/is_a.luau) allows for transitive inheritance relationships. In essence, this means that you can express an entity as being equivalent to another, without the reverse needing to be true.

A nice use of this is for entity prefabs, allowing you to have a "template" entity you can create copies of via adding the relationship.
```luau
local IsA = hammer.is_a(world)

local Spaceship = world:component()
world:set(Spaceship, Health, 250)
world:set(Spaceship, Shields, 50)
world:set(Spaceship, Damage, 35)
world:set(Spaceship, Position, vector.create(100, 20, 100))
world:set(Spaceship, Velocity, vector.create(10, 0, 4))

local my_spaceship = world:entity()
world:add(my_spaceship, pair(IsA, Spaceship))
-- `my_spaceship` now has all of the components of `Spaceship`, alongside the component `Spaceship` itself. Be careful while iterating spaceships though - to not include the prefab, make sure to add `pair(IsA, Spaceship)` to your query!
-- You can override the components by operating on the world like usual:
world:set(spaceship, Health, 230)
```

A further read can be found at the [Flecs relationships article](https://www.flecs.dev/flecs/md_docs_2Relationships.html#the-isa-relationship), and specifically the section about IsA relationships.

The implementation is based on [the IsA gist](https://gist.github.com/Ukendio/0d839428324bd10b7e4a16568cb856c8) created by the Jecs author, albeit further optimized to skip creating intermediate archetypes.

## ⚖️ License

This project is licensed under the terms of the MIT license. To further explore the terms, read [here](/LICENSE).
