--!nonstrict
--!optimize 2

--- Collects events into a flushable queue.
--- Supports signals which are functions or have `:connect` or `:Connect` methods, and supports callbacks, `:disconnect`, `:Disconnect`, `:destroy` and `:Destroy` for cleanup.
--- Example usage:
--- ```luau
--- local players_added = hammer.collect(Players.PlayerAdded)
--- local function system()
---     for i, player in players_added do
---         ...
---     end
--- end
--- ```
local function collect(event)
    local storage = {}

    local i = 0
    local function connector(...)
        table.insert(storage, { ... })
        i += 1
    end

    local n = 0
    local function iter()
        if n == i then
            n, i = 0, 0
            return
        end
        n += 1

        local args = table.remove(storage, 1)
        return n, unpack(args)
    end

    local disconnect
    if typeof(event) == "table" then
        local connect = event.connect or event.Connect
        disconnect = connect(event, connector)
    else
        disconnect = event(connector)
    end

    local function cleanup()
        if not disconnect then
            return
        end

        if typeof(disconnect) == "function" then
            disconnect()
        elseif typeof(disconnect) == "table" then
            if disconnect.disconnect then
                disconnect:disconnect()
            elseif disconnect.Disconnect then
                disconnect:Disconnect()
            elseif disconnect.destroy then
                disconnect:destroy()
            elseif disconnect.Destroy then
                disconnect:Destroy()
            end
        elseif typeof(disconnect) == "RBXScriptConnection" then
            disconnect:Disconnect()
        end
    end

    return iter, cleanup
end

type Iterator<T...> = () -> (number, T...)
type Connectable<T...> = (T...) -> ()
type Cleanup = () -> ()

-- stylua: ignore
return collect ::
    & (
        <R, T...>(
            (Connectable<T...>) -> R
        ) -> (Iterator<T...>, Cleanup)
    ) & (
        <S, R, T...>(S & {
            connect: (S, Connectable<T...>) -> R,
        }) -> (Iterator<T...>, Cleanup)
    ) & (
        <S, R, T...>(S & {
            Connect: (S, Connectable<T...>) -> R,
        }) -> (Iterator<T...>, Cleanup)
    ) & (
        <T...>(
            (Connectable<T...>) -> ()
        ) -> (Iterator<T...>, Cleanup)
    ) & (
        <S, T...>(S & {
            connect: (S, Connectable<T...>) -> (),
        }) -> (Iterator<T...>, Cleanup)
    ) & (
        <S, T...>(S & {
            Connect: (S, Connectable<T...>) -> (),
        }) -> (Iterator<T...>, Cleanup)
    )
