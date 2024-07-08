---@diagnostic disable: deprecated
local composer = require( "composer" )
local Utils = require("src.helper.utils")
local App = require("src.helper.app")
local MCTS = require("src.helper.mcts")
local Minimax = require("src.helper.minimax")

local scene = composer.newScene()

local level = 0
local levelTxt
local musicSound
local clickSound
local backgroundMusicChannel = nil
local isStarted = false
local boardGroup = nil
local promptTxt
local gap = 30
local cells = nil
local PLAYER_TURN = 1
local ROBOT_TURN = -1
local MATCH_COUNT = 3
local DIR_RIGHT = 1
local DIR_BOTTOM = 2
local DIR_RIGHT_TOP = 3
local DIR_RIGHT_BOT = 4
local mcts = nil
local firstPlayer = 1
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
local function onBtnBack()
    composer.gotoScene( "src.scene.menu", { effect="slideUp", time=200 } )
end

local function onBtnSettings(event)
    composer.gotoScene( "src.scene.settings", 
                        { effect="slideLeft", time=200, params={fromPlay=true} } )
end

local function getGridCount()
    return 2 + level
end

local function local2item(x, y)
    local size = display.actualContentWidth - gap * 2
    local grid = getGridCount()

    x = x + size / 2
    y = y + size / 2

    if x < 0 or x >= size or y < 0 or y >= size then
        return 0
    end
    size = size / grid
    return math.floor(y / size) * grid + math.floor(x / size) + 1
end

local function item2local(index)
    local size = display.actualContentWidth - gap * 2
    local grid = getGridCount()

    if index <= 0 or index > grid * grid then
        return nil
    end
    
    index = index - 1
    size = size / grid

    return {(index % grid) * size + size / 2 + gap, math.floor(index / grid) * size + display.contentCenterY - size * (grid - 1) / 2 }
end

local function removeAllChildren(group)
    while group.numChildren > 0 do
        local child = group[1]  -- Get the first child in the group
        display.remove(child)   -- Remove the child
    end
end

local function itemIndexFromPos(x, y)
    return x + (y - 1) * getGridCount()
end

local function createMatchLine(startX, startY, direction)
    local size = display.actualContentWidth - gap * 2
    local grid = getGridCount()
    local image = "Assets/Images/bar_w.png"
    local barSize, endX, endY, angle
    local delta = MATCH_COUNT - 1

    endX = startX
    endY = startY
    barSize = size / grid * MATCH_COUNT
    if direction == DIR_RIGHT then
        endX = endX + delta
        angle = 90
    elseif direction == DIR_BOTTOM then
        endY = endY + delta
        angle = 0
    elseif direction == DIR_RIGHT_BOT then
        endX = endX + delta
        endY = endY + delta
        barSize = barSize * 1.3
        angle = -45
    else
        endX = endX + delta
        endY = endY - delta
        barSize = barSize * 1.3
        angle = 45
    end
    
    local pos1 = item2local(itemIndexFromPos(startX, startY))
    local pos2 = item2local(itemIndexFromPos(endX, endY))

    if pos1 ~= nil and pos2 ~= nil then
        local bar = Utils.createImage( boardGroup, image, nil, barSize, (pos1[1] + pos2[1]) / 2, (pos1[2] + pos2[2]) / 2 )
        bar.rotation = angle
    end
end

local function checkGameEnd(state, render)
    local grid = getGridCount()
    local matched = false

    for x = 1, grid do
        local match = 1
        for y = 1, grid - 1 do
            local pos = state[itemIndexFromPos(x, y)]
            if pos ~= 0 and pos == state[itemIndexFromPos(x, y + 1)] then
                match = match + 1
            else
                match = 1
            end
            if match == MATCH_COUNT then
                matched = true
                if render then
                    createMatchLine(x, y - MATCH_COUNT + 2, DIR_BOTTOM)
                end
                break
            end
        end

        if matched then
            break
        end
    end

    if not matched then
        for y = 1, grid do
            local match = 1
            for x = 1, grid - 1 do
                local pos = state[itemIndexFromPos(x, y)]
                if pos ~= 0 and pos == state[itemIndexFromPos(x + 1, y)] then
                    match = match + 1
                else
                    match = 1
                end
                if match == MATCH_COUNT then
                    matched = true
                    if render then
                        createMatchLine(x - MATCH_COUNT + 2, y, DIR_RIGHT)
                    end
                    break
                end
            end
    
            if matched then
                break
            end
        end
    end
    
    if not matched then
        for x = 1, grid - MATCH_COUNT + 1 do
            local match = 1
            for y = 1, grid - MATCH_COUNT + 1 do
                local pos = state[itemIndexFromPos(x, y)]
                if pos ~= 0 then
                    matched = true
                    for i = 1, MATCH_COUNT - 1 do
                        if pos ~= state[itemIndexFromPos(x + i, y + i)] then
                            matched = false
                            break
                        end
                    end
                    if matched then
                        if render then
                            createMatchLine(x, y, DIR_RIGHT_BOT)
                        end
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
        for x = 1, grid - MATCH_COUNT + 1 do
            local match = 1
            for y = MATCH_COUNT, grid do
                local pos = state[itemIndexFromPos(x, y)]
                if pos ~= 0 then
                    matched = true
                    for i = 1, MATCH_COUNT - 1 do
                        if pos ~= state[itemIndexFromPos(x + i, y - i)] then
                            matched = false
                            break
                        end
                    end
                    if matched then
                        if render then
                            createMatchLine(x, y, DIR_RIGHT_TOP)
                        end
                        break
                    end
                end
            end
    
            if matched then
                break
            end
        end
    end

    if matched then
        if render then
            isStarted = false
        end
    end

    return matched
end

local function putStone(index, kind)
    local pos = item2local(index)
    if pos ~= nil and cells ~= nil and cells[index] == 0 then
        cells[index] = kind

        if kind < 0 then
            kind = 2
        end

        local size = (display.actualContentWidth - gap * 2) * 0.8 / getGridCount()
        Utils.createImage( boardGroup, "Assets/Images/stone_"..kind..".png", size, nil, pos[1], pos[2] )

        return true
    end

    return false
end


local function performAsyncCalculation(callback)
    -- Simulate a time-consuming calculation
    local result = 0

    -- result = Minimax.findBestMove(cells, getGridCount())

    if mcts ~= nil then
        -- Run MCTS to get the best action
        result = mcts:getAction(1000, getGridCount(), cells, -1)
    else
        while isStarted do
            result = math.random(#cells)
            if cells ~= nil and cells[result] == 0 then
                break
            end
        end
    end

    -- Invoke the callback with the result
    callback(result)
end

local function asyncCalculationCoroutine(callback)
    -- Start the calculation in a new thread
    local thread = coroutine.create(function()
        performAsyncCalculation(callback)
    end)

    -- Resume the coroutine to start the calculation
    coroutine.resume(thread)
end

local function playerTurn()
    if promptTxt ~= nil then
        promptTxt.isVisible = true
    end
end

local function gotoResultScene()
	timer.performWithDelay( 1000, function( )
        local parameter = {}
        parameter["level"] = level

        local sceneName
        if promptTxt.isVisible then
            if level >= App.getMaxLevel() then
                sceneName = "src.scene.finish"
            else
                sceneName = "src.scene.win"
            end
        else
            sceneName = "src.scene.lose"
        end
        composer.gotoScene( sceneName, { effect="slideRight", time=200, params = parameter } )
    end )
end

local function robotTurn()
    if promptTxt ~= nil then
        promptTxt.isVisible = false
        asyncCalculationCoroutine(function(result)
            if result > 0 and isStarted then
                if putStone(result, ROBOT_TURN) then
                    checkGameEnd(cells, true)

                    if isStarted then
                        playerTurn()
                    else
                        gotoResultScene()
                    end
                end
            end
        end)
    end
end

local function onBoardClick(event)
    if promptTxt ~= nil and promptTxt.isVisible and isStarted then
        local tappedObject = event.target  -- Get the tapped object
        local x, y = tappedObject:contentToLocal(event.x, event.y)  -- Convert tap coordinates to local coordinates of the object
        local index = local2item(x, y)
        if index > 0 then
            if putStone(index, PLAYER_TURN) then
                if App.getPreferenceEffect() then
                    audio.play( clickSound )
                end

                checkGameEnd(cells, true)

                if isStarted then
                    if mcts ~= nil then
                        mcts:doAction(index)
                    end
                    robotTurn()
                else
                    gotoResultScene()
                end
            end
        end
    end
end

local function onBtnRestart()
    cells = {}

    if boardGroup ~= nil then
        boardGroup:removeSelf()
    end

    boardGroup = display.newGroup()
    local grid = getGridCount()

    local player = 1
    if firstPlayer % 2 == 0 then
        player = -1 -- robot
    end
    
    firstPlayer = firstPlayer + 1

    mcts = MCTS:new()

    for i = 1, grid * grid do
        cells[i] = 0  -- Initialize each element with a default value
    end

    local size = display.actualContentWidth - gap * 2
    for i = 1, grid - 1 do
        local index = math.random(2)
        local bar_h = Utils.createImage( boardGroup, "Assets/Images/bar_h"..index..".png", 
        size, nil, display.contentCenterX, 0 )
        bar_h.y = display.contentCenterY - size / 2 + size * i / grid
        local bar_v = Utils.createImage( boardGroup, "Assets/Images/bar_v"..index..".png", 
                                    nil, size, 0, display.contentCenterY )
        bar_v.x = display.contentCenterX - size / 2 + size * i / grid
    end

    scene.view:insert( boardGroup )

    isStarted = true

    if player == 1 then
        playerTurn()
    else
        robotTurn()
    end
    
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
    musicSound = audio.loadSound( "Assets/Sounds/playing.wav" )
    clickSound = audio.loadSound( "Assets/Sounds/click.wav" )

    local sceneGroup = self.view
 
    local bgGradient = App.createBgGradient()
    sceneGroup:insert( bgGradient )

    local btn_back = Utils.createImage( nil, "Assets/Images/btn_back.png", 40, nil, 0, 0 )
    btn_back.x = Utils.getLeftInScreen() + btn_back.contentWidth
    btn_back.y = Utils.getTopInScreen() + btn_back.contentHeight
    sceneGroup:insert( btn_back )
    btn_back:addEventListener("tap", onBtnBack)

    local btn_settings = Utils.createImage( nil, "Assets/Images/btn_gear.png", 40, nil, Utils.getRightInScreen() - btn_back.contentWidth, btn_back.y )
    sceneGroup:insert( btn_settings )
    btn_settings:addEventListener("tap", onBtnSettings)

    local fontSize = 40
    levelTxt = Utils.createText(nil, "", fontSize, display.contentCenterX, fontSize)
    levelTxt:setFillColor(unpack(App.getPrimaryTextColor()))
    sceneGroup:insert( levelTxt )

    local btn_restart = Utils.createImage( nil, "Assets/Images/btn_restart.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, 0 )
    btn_restart.y = Utils.getBottomInScreen() - btn_restart.contentHeight
    sceneGroup:insert( btn_restart )
    btn_restart:addEventListener("tap", onBtnRestart)

    promptTxt = Utils.createText(nil, "TOUCH CELL", 30, display.contentCenterX, btn_restart.y - fontSize * 1.5)
    sceneGroup:insert( promptTxt )
    promptTxt.isVisible = false

    bgGradient:addEventListener("tap", onBoardClick)
end

-- show()
function scene:show( event )
 
    local phase = event.phase
 
    if ( phase == "will" ) then
    elseif ( phase == "did" ) then
        if App.getPreferenceMusic() then
            backgroundMusicChannel = audio.play( musicSound, { loops=-1 } )
        end
        local destLevel = App.getPreferenceLevel()
        if destLevel <= 0 then
            destLevel = 1
        end

        if event.params ~= nil then
            if event.params.level ~= nil then
                destLevel = event.params.level
            end
        end

        if level ~= destLevel or not isStarted then
            level = destLevel
            onBtnRestart()
        end

        levelTxt.text = "LEVEL"..level
    end
end
 
-- hide()
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        if backgroundMusicChannel ~= nil then
            audio.stop(backgroundMusicChannel)
            backgroundMusicChannel = nil
        end
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
 
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene