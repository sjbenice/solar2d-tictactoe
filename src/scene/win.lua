---@diagnostic disable: deprecated
local composer = require( "composer" )
local Utils = require("src.helper.utils")
local switch = require("src.helper.switch")
local App = require("src.helper.app")

local scene = composer.newScene()
local isFromPlay = false
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local message, score
local level = 0
local winSound

local function onBtnBack()
    composer.gotoScene( "src.scene.play", { effect="slideRight", time=200 } )
end

local function onBtnNextLevel()
    App.setPreferenceLevel(level + 1)

    local parameter = {}
    parameter["level"] = level + 1
    composer.gotoScene( "src.scene.play", 
        {
            effect="slideDown", time=200, 
            params = parameter 
        } )
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
    winSound = audio.loadSound( "Assets/Sounds/win.wav" )

    local sceneGroup = self.view
 
    local bgGradient = App.createBgGradient()
    sceneGroup:insert( bgGradient )
    local btn_back = Utils.createImage( nil, "Assets/Images/btn_back.png", 40, nil, 0, 0 )
    btn_back.x = Utils.getLeftInScreen() + btn_back.contentWidth
    btn_back.y = Utils.getTopInScreen() + btn_back.contentHeight
    sceneGroup:insert( btn_back )
    btn_back:addEventListener("tap", onBtnBack)

    local level = Utils.createImage( nil, "Assets/Images/level.png", 120, nil, display.contentCenterX, display.contentCenterY )
    level.y = Utils.getTopInScreen() + level.contentHeight * 1.5
    sceneGroup:insert( level )

    local dlg = Utils.createImage( nil, "Assets/Images/dlg.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, display.contentCenterY )
    sceneGroup:insert( dlg )

    local fontSize = 40
    message = Utils.createText(nil, "", fontSize, display.contentCenterX, display.contentCenterY - fontSize)
    sceneGroup:insert( message )
    local complete = Utils.createText(nil, "COMPLETE", fontSize, display.contentCenterX, display.contentCenterY)
    sceneGroup:insert( complete )
    local your_score = Utils.createText(nil, "YOUR SCORE", fontSize * .5, display.contentCenterX, display.contentCenterY + fontSize)
    your_score:setFillColor(unpack(App.getPrimaryTextColor()))
    sceneGroup:insert( your_score )
    score = Utils.createText(nil, "", fontSize * .9, display.contentCenterX, display.contentCenterY + fontSize * 1.6)
    score:setFillColor(unpack(App.getPrimaryTextColor()))
    sceneGroup:insert( score )

    local btn_next = Utils.createImage( nil, "Assets/Images/btn_next.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, 0 )
    btn_next.y = Utils.getBottomInScreen() - btn_next.contentHeight
    sceneGroup:insert( btn_next )

    btn_next:addEventListener("tap", onBtnNextLevel)
end

-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        if event.params ~= nil then
            if event.params.level ~= nil then
                level = event.params.level
            end
        end

        message.text = "LEVEL"..level

        local value = App.getPreferenceLevelScore(level)
        value = value + 1
        App.setPreferenceLevelScore(level, value)
        score.text = value
    elseif ( phase == "did" ) then
        if App.getPreferenceEffect() then
            audio.play( winSound )
        end
        if App.getPreferenceVibro() then
            if event.device and event.device.canVibrate then
                event.device:vibrate()
            end
        end
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
-- -----------------------------------------------------------------------------------
 
return scene