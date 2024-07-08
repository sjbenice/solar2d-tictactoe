local composer = require( "composer" )
local Utils = require("src.helper.utils")
local App = require("src.helper.app")

local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
local function onBtnStart()
    composer.gotoScene( "src.scene.menu", { effect="slideLeft", time=200 } )
    composer.removeScene( scene )
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
 
    local bgGradient = App.createBgGradient()
    local bgBuilding = Utils.createImage( nil, "Assets/Images/building.png", display.actualContentWidth, nil, display.contentCenterX, display.contentCenterY )

    sceneGroup:insert( bgGradient )
    sceneGroup:insert( bgBuilding )

    local title = Utils.createImage( nil, "Assets/Images/title.png", 240, nil, display.contentCenterX, 0 )
    title.y = display.contentCenterY - bgBuilding.contentHeight / 2 - title.contentHeight / 2
    local minY = Utils.getTopInScreen() + title.contentHeight
    if title.y < minY then
        title.y = minY
    end
    sceneGroup:insert( title )

    btn_start = Utils.createImage( nil, "Assets/Images/btn_start.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, 0 )
    btn_start.y = Utils.getBottomInScreen() - btn_start.contentHeight
    sceneGroup:insert( btn_start )

    -- btn_start.onTap = onBtnStart
    -- btn_start:addEventListener("touch", Utils.createButtonTouchHandler(btn_start.onTap))
    btn_start:addEventListener("tap", onBtnStart)
end
 
scene:addEventListener( "create", scene )
 
return scene