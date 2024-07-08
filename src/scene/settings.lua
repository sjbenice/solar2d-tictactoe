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
local musicSwitch, effectSwitch, vibroSwitch

local function onBtnBack()
    local params = { effect="slideRight", time=200 }
    if isFromPlay then
        composer.gotoScene( "src.scene.play", params )
    else
        composer.gotoScene( "src.scene.menu", params )
    end
end

local function onBtnSave()
    App.setPreferenceMusic(musicSwitch:getState())
    App.setPreferenceEffect(effectSwitch:getState())
    App.setPreferenceVibro(vibroSwitch:getState())

    onBtnBack()
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
 
    local bgGradient = App.createBgGradient()
    sceneGroup:insert( bgGradient )
    local btn_back = Utils.createImage( nil, "Assets/Images/btn_back.png", 40, nil, 0, 0 )
    btn_back.x = Utils.getLeftInScreen() + btn_back.contentWidth
    btn_back.y = Utils.getTopInScreen() + btn_back.contentHeight
    sceneGroup:insert( btn_back )
    btn_back:addEventListener("tap", onBtnBack)

    local dlg = Utils.createImage( nil, "Assets/Images/dlg.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, display.contentCenterY )
    sceneGroup:insert( dlg )

    local caption = Utils.createText(nil, "SETTINGS", 35, display.contentCenterX, display.contentCenterY - dlg.contentHeight / 2 - 40)
    sceneGroup:insert( caption )

    local fontSize = 30
    local music = Utils.createText(nil, "MUSIC", fontSize, display.contentCenterX - fontSize * 2, display.contentCenterY - fontSize * 2)
    music:setFillColor(unpack(App.getPrimaryTextColor()))
    sceneGroup:insert( music )
    local effect = Utils.createText(nil, "EFFCT", fontSize, music.x, display.contentCenterY)
    effect:setFillColor(unpack(App.getPrimaryTextColor()))
    sceneGroup:insert( effect )
    local vibro = Utils.createText(nil, "VIBRO", fontSize, music.x, display.contentCenterY + fontSize * 2)
    vibro:setFillColor(unpack(App.getPrimaryTextColor()))
    sceneGroup:insert( vibro )

    musicSwitch = switch.new({
        width = nil,
        height = fontSize,
        x = display.contentCenterX + fontSize * 2,
        y = music.y,
        onImage = "Assets/Images/switch_on.png",
        offImage = "Assets/Images/switch_off.png",
        -- onStateChanged = function(isOn)
        --     print("Switch state changed:", isOn and "On" or "Off")
        -- end
    })
    sceneGroup:insert( musicSwitch )

    effectSwitch = switch.new({
        width = nil,
        height = fontSize,
        x = display.contentCenterX + fontSize * 2,
        y = effect.y,
        onImage = "Assets/Images/switch_on.png",
        offImage = "Assets/Images/switch_off.png",
        -- onStateChanged = function(isOn)
        --     print("Switch state changed:", isOn and "On" or "Off")
        -- end
    })
    sceneGroup:insert( effectSwitch )

    vibroSwitch = switch.new({
        width = nil,
        height = fontSize,
        x = display.contentCenterX + fontSize * 2,
        y = vibro.y,
        onImage = "Assets/Images/switch_on.png",
        offImage = "Assets/Images/switch_off.png",
        -- onStateChanged = function(isOn)
        --     print("Switch state changed:", isOn and "On" or "Off")
        -- end
    })
    sceneGroup:insert( vibroSwitch )

    local btn_save = Utils.createImage( nil, "Assets/Images/btn_save.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, 0 )
    btn_save.y = Utils.getBottomInScreen() - btn_save.contentHeight
    sceneGroup:insert( btn_save )

    btn_save:addEventListener("tap", onBtnSave)
end

-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Read the preferences that were written to storage above
        musicSwitch:setState(App.getPreferenceMusic())
        effectSwitch:setState(App.getPreferenceEffect())
        vibroSwitch:setState(App.getPreferenceVibro())

        isFromPlay = (event ~= nil and event.params ~= nil and event.params.fromPlay ~= nil)
    elseif ( phase == "did" ) then
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
-- -----------------------------------------------------------------------------------
 
return scene