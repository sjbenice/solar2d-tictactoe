-- Simple MCTS implementation in Lua
local State = require("src.helper.state")
local Utils = require("src.helper.utils")

-- Tree node structure
local Node = {}
Node.__index = Node

function Node:new(parent, player, action, availableActions)
    local this = {
        parent = parent,
        player = player,
        action = action,
        children = {},
        _Q = 0,
        _u = 0,
        _n_visits = 0,
        availableActions = availableActions,
    }

    if parent ~= nil and availableActions == nil then
        this.availableActions = {}
        for i = 1, #parent.availableActions do
            if parent.availableActions[i] ~= action then
                this.availableActions[#this.availableActions + 1] = parent.availableActions[i]
            end
        end
    end
    setmetatable(this, Node)
    return this
end

function Node:print()
    print("action="..self.action..",player="..self.player..",children="..#self.children)
    if self.availableActions ~= nil then
        for i = 1, #self.availableActions do
            io.write(self.availableActions[i]..",")
        end
        io.write("\n")
    end
end

-- Select a child node using UCB1
function Node:selectChild()
    local selected
    local bestValue = -math.huge

    for _, child in ipairs(self.children) do
        local value = child:value()
        -- print(child.player, child.action, value)
        if value > bestValue then
            selected = child
            bestValue = value
        end
    end
    return selected
end

-- Add a new child node
function Node:expand()
    if self.availableActions == nil or not self:isLeaf() then
        return 0
    end

    for i = 1, #self.availableActions do
        local child = Node:new(self, -self.player, self.availableActions[i], nil)
        table.insert(self.children, child)
    end

    return #self.children
end

-- Update the node after simulation
function Node:update(result)
    self._n_visits = self._n_visits + 1
    self._Q = self._Q + 1.0*(result - self._Q) / self._n_visits
end

function Node:value()
    self._u = (2 * math.sqrt(self.parent._n_visits) / (1 + self._n_visits))
    return self._Q + self._u
end

function Node:isLeaf()
    return #self.children == 0
end

local MCTS = {}

function MCTS:new()
    local newObj = {root = nil}  -- Create a new object
    self.__index = self
    self.root = nil

    return setmetatable(newObj, self)  -- Set MyClass as the metatable for newObj
end

function MCTS:hasEndAction(state, player)
    for i = 1, state.dimension do
        for j = 1, state.dimension do
            local pos = state:itemIndexFromPos(i, j)
            if state.state[pos] == 0 then
                state.state[pos] = player
                if state:isTerminal() then
                    state.state[pos] = 0
                    return pos
                end
                state.state[pos] = 0                    
            end
        end
    end

    return 0
end

-- MCTS main algorithm
function MCTS:getAction(playout, dimension, data, player)
    local startState = State:new(dimension, data)

    local endPos = self:hasEndAction(startState, -1)
    if endPos == 0 then
        endPos = self:hasEndAction(startState, 1)
    end

    if endPos ~= 0 then
        self:doAction(endPos)
        return endPos
    end

    if self.root == nil then
        self.root = Node:new(nil, player * -1, 0, startState:getLegalActions())
    end

    local rootNode = self.root

    for i = 1, playout do
        -- print("playout:"..i.."/"..playout)
        local node = rootNode
        local workState = State:new(startState.dimension, startState.state)

        while true do
            if node:isLeaf() then
                break
            end
            -- Greedily select next move.
            node = node:selectChild()
            workState:doAction(node.action * node.player)
        end

        local result = 0
        if workState:isTerminal() then
            result = -1
            break
        else
            node:expand()
        end

        while node do
            node:update(result)
            node = node.parent
            result = result * -1
        end
    end

    -- Return the move that was most visited
    local select = rootNode:selectChild()
    self:doAction(select.action)

    return select.action
end

function MCTS:doAction(action)
    -- self.root = nil
    if self.root ~= nil then
        if #self.root.children <= 0 then
            self.root:expand()
        end
        for _, child in ipairs(self.root.children) do
            if child.action == action then
                self.root = child
                child.parent = nil
                return
            end
        end
        print( "ERROR:Can't do action for "..action )
    else        
        print( "Root is empty" )
    end
end

return MCTS
