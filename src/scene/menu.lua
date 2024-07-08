local composer = require( "composer" )
local Utils = require("src.helper.utils")
local App = require("src.helper.app")

local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
local function onBtnPlayGame()
    composer.gotoScene( "src.scene.play", { effect="slideDown", time=200 } )
end

local function onBtnSettings()
    composer.gotoScene( "src.scene.settings", { effect="slideLeft", time=200 } )
end

local function onBtnScoreBoard()
    composer.gotoScene( "src.scene.score", { effect="slideLeft", time=200 } )
end

local function onBtnExit()
    composer.gotoScene( "src.scene.exit", { effect="slideLeft", time=200 } )
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
 
    local bgGradient = App.createBgGradient()
    local bgBuilding = Utils.createImage( nil, "Assets/Images/building2.png", display.actualContentWidth, nil, display.contentCenterX, display.contentCenterY )
    bgBuilding.y = display.contentCenterY - bgBuilding.contentHeight / 2
    sceneGroup:insert( bgGradient )
    sceneGroup:insert( bgBuilding )

    local btn_exit = Utils.createImage( nil, "Assets/Images/btn_exit.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, 0 )
    btn_exit.y = Utils.getBottomInScreen() - btn_exit.contentHeight
    sceneGroup:insert( btn_exit )

    btn_exit:addEventListener("tap", onBtnExit)

    local btn_settings = Utils.createImage( nil, "Assets/Images/btn_settings.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, display.contentCenterY )
    sceneGroup:insert( btn_settings )

    btn_settings:addEventListener("tap", onBtnSettings)

    local btn_play = Utils.createImage( nil, "Assets/Images/btn_play.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, display.contentCenterY - btn_settings.contentHeight * 1.5 )
    sceneGroup:insert( btn_play )

    btn_play:addEventListener("tap", onBtnPlayGame)

    local btn_scoreboard = Utils.createImage( nil, "Assets/Images/btn_scoreboard.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, display.contentCenterY + btn_settings.contentHeight * 1.5 )
    sceneGroup:insert( btn_scoreboard )

    btn_scoreboard:addEventListener("tap", onBtnScoreBoard)
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
 
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
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