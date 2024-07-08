---@diagnostic disable: deprecated
local composer = require( "composer" )
local Utils = require("src.helper.utils")
local switch = require("src.helper.switch")
local App = require("src.helper.app")

local scene = composer.newScene()
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local message, score
local level = 0
local loseSound

local function onBtnAgain()
    local parameter = {}
    parameter["level"] = level
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
    loseSound = audio.loadSound( "Assets/Sounds/lose.wav" )

    local sceneGroup = self.view
 
    local bgGradient = App.createBgGradient()
    sceneGroup:insert( bgGradient )

    local level = Utils.createImage( nil, "Assets/Images/fish.png", 150, nil, display.contentCenterX, display.contentCenterY )
    level.y = Utils.getTopInScreen() + level.contentHeight
    sceneGroup:insert( level )

    local fontSize = 40
    message = Utils.createText(nil, "", fontSize, display.contentCenterX, display.contentCenterY - fontSize)
    sceneGroup:insert( message )
    local complete = Utils.createText(nil, "YOU LOSE", fontSize, display.contentCenterX, display.contentCenterY)
    sceneGroup:insert( complete )
    local your_score = Utils.createText(nil, "YOUR SCORE", fontSize * .5, display.contentCenterX, display.contentCenterY + fontSize)
    your_score:setFillColor(unpack(App.getPrimaryTextColor()))
    sceneGroup:insert( your_score )
    score = Utils.createText(nil, "", fontSize * .9, display.contentCenterX, display.contentCenterY + fontSize * 1.6)
    score:setFillColor(unpack(App.getPrimaryTextColor()))
    sceneGroup:insert( score )

    local btn_again = Utils.createImage( nil, "Assets/Images/btn_again.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, 0 )
    btn_again.y = Utils.getBottomInScreen() - btn_again.contentHeight
    sceneGroup:insert( btn_again )

    btn_again:addEventListener("tap", onBtnAgain)
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
        if (value > 0) then
            value = value - 1
            App.setPreferenceLevelScore(level, value)
        end
        score.text = value
    elseif ( phase == "did" ) then
        if App.getPreferenceEffect() then
            audio.play( loseSound )
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