local Utils = require("src.helper.utils")
-- Module table
local State = {}
local MATCH_COUNT = 3

-- player : 1, robot : -1
function State:new(dimension, data)
    local state
    if data == nil then
        state = {}
        for i = 1, dimension * dimension do
            state[i] = 0
        end
    else
        state = Utils.copyTable(data)
    end

    local newObj = {dimension = dimension, state = state }  -- Create a new object
    self.__index = self

    return setmetatable(newObj, self)  -- Set MyClass as the metatable for newObj
end

function State:print()
    for i = 1, #self.state do
        io.write(self.state[i]..",")
        if i % self.dimension == 0 then
            io.write("\n")
        end
    end
end

-- Define a member function
function State:getLegalActions()
    -- Returns a list of all possible actions from the current state.
    local actions = {}
    for i = 1, #self.state do
        if self.state[i] == 0 then
            actions[#actions + 1] = i
        end
    end

    return actions
end

function State:doAction(action)
    -- Updates the state with the given action.
    local abs = math.abs(action)
    if self.state[abs] ~= 0 then
        print ( "Error to do action already done "..action)
    end
    self.state[abs] = math.floor(abs / action)
end

function State:itemIndexFromPos(x, y)
    return x + (y - 1) * self.dimension
end

function State:isTerminal()
    -- Checks if the current state is a terminal state (end of the game).
    local matched = false

    for x = 1, self.dimension do
        local match = 1
        for y = 1, self.dimension - 1 do
            local pos = self.state[self:itemIndexFromPos(x, y)]
            if pos ~= 0 and pos == self.state[self:itemIndexFromPos(x, y + 1)] then
                match = match + 1
            else
                match = 1
            end
            if match == MATCH_COUNT then
                matched = true
                break
            end
        end

        if matched then
            break
        end
    end

    if not matched then
        for y = 1, self.dimension do
            local match = 1
            for x = 1, self.dimension - 1 do
                local pos = self.state[self:itemIndexFromPos(x, y)]
                if pos ~= 0 and pos == self.state[self:itemIndexFromPos(x + 1, y)] then
                    match = match + 1
                else
                    match = 1
                end
                if match == MATCH_COUNT then
                    matched = true
                    break
                end
            end
    
            if matched then
                break
            end
        end
    end
    
    if not matched then
        for x = 1, self.dimension - MATCH_COUNT + 1 do
            local match = 1
            for y = 1, self.dimension - MATCH_COUNT + 1 do
                local pos = self.state[self:itemIndexFromPos(x, y)]
                if pos ~= 0 then
                    matched = true
                    for i = 1, MATCH_COUNT - 1 do
                        if pos ~= self.state[self:itemIndexFromPos(x + i, y + i)] then
                            matched = false
                            break
                        end
                    end
                    if matched then
                        break
                    end
                end
            end
    
            if matched then
                break
            end
        end
    end

    if not matched then
        for x = 1, self.dimension - MATCH_COUNT + 1 do
            local match = 1
            for y = MATCH_COUNT, self.dimension do
                local pos = self.state[self:itemIndexFromPos(x, y)]
                if pos ~= 0 then
                    matched = true
                    for i = 1, MATCH_COUNT - 1 do
                        if pos ~= self.state[self:itemIndexFromPos(x + i, y - i)] then
                            matched = false
                            break
                        end
                    end
                    if matched then
                        break
                    end
                end
            end
    
            if matched then
                break
            end
        end
    end

    return matched
end

return State