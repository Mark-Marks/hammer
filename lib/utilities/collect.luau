--!strict
--!optimize 2
--[[
original author by @memorycode

MIT License

Copyright (c) 2024 Michael

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]]

--- What signals passed to `collect()` should be able to be coerced into
export type SignalLike<D, T...> = { connect: Connector<D, T...>, [any]: any } | { Connect: Connector<D, T...>, [any]: any }
type Connector<D, T...> = (self: SignalLike<D, T...>, (T...) -> ()) -> D

--- Collects all arguments fired through the given signal, and drains the collection on iteration.\
--- Expects signals to have a `Connect` or `connect` ***method***.
local function collect<D, T...>(event: SignalLike<D, T...>): (() -> (number, T...), D)
    local storage = {}
    local mt = {}
    local iter = function()
        local n = #storage
        return function(): (number?, T...)
            if n <= 0 then
                mt.__iter = nil
                return nil :: any
            end

            n -= 1
            return n + 1, unpack(table.remove(storage, 1) :: any) :: any
        end
    end

    local connect = event.Connect or event.connect
    assert(connect ~= nil, "Signal is missing a Connect function - is it really a signal?")
    local disconnect = connect(event, function(...)
        table.insert(storage, { ... })
        mt.__iter = iter :: any
    end)

    setmetatable(storage, mt)
    return storage :: any, disconnect
end

return collect
