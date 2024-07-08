local composer = require( "composer" )
local Utils = require("src.helper.utils")
local App = require("src.helper.app")

local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
local function onBtnYes()
    if system.getInfo("platform") == "android" then
        native.requestExit() -- Exit the application on Android
    else
        os.exit() -- Exit the application on other platforms
    end
end

local function onBtnNo()
    composer.gotoScene( "src.scene.menu", { effect="slideRight", time=200 } )
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
 
    local bgGradient = App.createBgGradient()
    sceneGroup:insert( bgGradient )

    local cap = Utils.createImage( nil, "Assets/Images/cap.png", 120, nil, display.contentCenterX, display.contentCenterY )
    cap.y = Utils.getTopInScreen() + cap.contentHeight
    sceneGroup:insert( cap )

    local btn_yes = Utils.createImage( nil, "Assets/Images/btn_yes.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, display.contentCenterY )
    btn_yes.y = display.contentCenterY - btn_yes.contentHeight * 0.6;
    sceneGroup:insert( btn_yes )

    btn_yes:addEventListener("tap", onBtnYes)

    local btn_no = Utils.createImage( nil, "Assets/Images/btn_no.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, display.contentCenterY + btn_yes.contentHeight * 0.6 )
    sceneGroup:insert( btn_no )

    btn_no:addEventListener("tap", onBtnNo)
    
    local circle = Utils.createImage( nil, "Assets/Images/circle.png", 120, nil, display.contentCenterX, display.contentCenterY )
    circle.y = Utils.getBottomInScreen() - circle.contentHeight
    sceneGroup:insert( circle )

    local exit = Utils.createText(nil, "EXIT?", 35, display.contentCenterX, btn_yes.y - btn_yes.contentHeight)
    sceneGroup:insert( exit )
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
-- -----------------------------------------------------------------------------------
 
return scene