---@diagnostic disable: deprecated
local composer = require( "composer" )
local Utils = require("src.helper.utils")
local App = require("src.helper.app")

local scene = composer.newScene()
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local message, score
local winSound

local function onBtnBack()
    composer.gotoScene( "src.scene.play", { effect="slideRight", time=200 } )
end

local function onBtnHome()
    composer.gotoScene( "src.scene.menu", { effect="fromBottom", time=200 } )
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

    local level = Utils.createImage( nil, "Assets/Images/flower.png", Utils.getPrimaryButtonWidth() * 0.8, nil, display.contentCenterX, display.contentCenterY )
    sceneGroup:insert( level )

    local dlg = Utils.createImage( nil, "Assets/Images/dlg.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, display.contentCenterY )
    sceneGroup:insert( dlg )

    level.y = dlg.y - dlg.contentHeight / 2 - level.contentHeight * 0.38

    local fontSize = 50
    message = Utils.createText(nil, "", fontSize, display.contentCenterX, display.contentCenterY - fontSize)
    sceneGroup:insert( message )
    local complete = Utils.createText(nil, "WINNER", fontSize, display.contentCenterX, display.contentCenterY)
    sceneGroup:insert( complete )
    local your_score = Utils.createText(nil, "YOU ARE A STAR!", fontSize * .5, display.contentCenterX, display.contentCenterY + fontSize)
    your_score:setFillColor(unpack(App.getPrimaryTextColor()))
    sceneGroup:insert( your_score )
    score = Utils.createText(nil, "", fontSize * .9, display.contentCenterX, display.contentCenterY + fontSize * 1.6)
    score:setFillColor(unpack(App.getPrimaryTextColor()))
    sceneGroup:insert( score )

    local btn_home = Utils.createImage( nil, "Assets/Images/btn_home.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, 0 )
    btn_home.y = Utils.getBottomInScreen() - btn_home.contentHeight
    sceneGroup:insert( btn_home )

    btn_home:addEventListener("tap", onBtnHome)
end

-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        if event.params ~= nil then
            if event.params.level ~= nil then
                local level = event.params.level
                local value = App.getPreferenceLevelScore(level)
                value = value + 1
                App.setPreferenceLevelScore(level, value)
                App.setPreferenceLevel(1)
            end
        end
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