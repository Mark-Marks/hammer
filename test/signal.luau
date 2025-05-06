-- licensed under MIT
-- @author jackdotink
-- https://github.com/red-blox/Util/blob/main/libs/Signal/Signal.luau
-- adapted to work in pure luau

type Node<T...> = {
    next: Node<T...>?,
    callback: (T...) -> (),
}

export type Signal<T...> = {
    root: Node<T...>?,

    connect: (self: Signal<T...>, Callback: (T...) -> ()) -> () -> (),
    wait: (self: Signal<T...>) -> T...,
    once: (self: Signal<T...>, Callback: (T...) -> ()) -> () -> (),
    fire: (self: Signal<T...>, T...) -> (),
    disconnect_all: (self: Signal<T...>) -> (),
}

local Signal = {}
Signal.__index = Signal

-- Extracted this function from Connect as it results in the closure
-- made in Connect using less memory because this function can be static
local function disconnect<T...>(self: Signal<T...>, Node: Node<T...>)
    if self.root == Node then
        self.root = Node.next
    else
        local Current = self.root

        while Current do
            if Current.next == Node then
                Current.next = Node.next
                break
            end

            Current = Current.next
        end
    end
end

function Signal.connect<T...>(self: Signal<T...>, Callback: (T...) -> ()): () -> ()
    local node = {
        next = self.root,
        callback = Callback,
    }

    self.root = node

    return function()
        disconnect(self, node)
    end
end

function Signal.wait<T...>(self: Signal<T...>): T...
    local Thread = coroutine.running()
    local Disconnect

    Disconnect = self:connect(function(...)
        (Disconnect :: any)()
        coroutine.resume(Thread, ...)
    end)

    return coroutine.yield()
end

function Signal.once<T...>(self: Signal<T...>, Callback: (T...) -> ()): () -> ()
    local Disconnect

    Disconnect = self:connect(function(...)
        (Disconnect :: any)()
        Callback(...)
    end)

    return Disconnect
end

function Signal.fire<T...>(self: Signal<T...>, ...: T...)
    local Current = self.root

    while Current do
        Current.callback(...)
        Current = Current.next
    end
end

function Signal.disconnect_all<T...>(self: Signal<T...>)
    self.root = nil
end

return function<T...>(): Signal<T...>
    return setmetatable({
        root = nil,
    }, Signal) :: any
end
