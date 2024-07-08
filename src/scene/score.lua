---@diagnostic disable: deprecated
local composer = require( "composer" )
local Utils = require("src.helper.utils")
local App = require("src.helper.app")

local scene = composer.newScene()
local scores = {}
local scoreBoxs = {}
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function onBtnBack()
    composer.gotoScene( "src.scene.menu", { effect="slideRight", time=200 } )
end

local function onBtnReset()
    for i = 1, #scores do
        scores[i] = 0
        App.setPreferenceLevelScore(i, 0)
    end

    scene:render()
end

local function onBtnScore(event)
    local button = event.target
    local parameter = {}
    parameter["level"] = button.level
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
 
    local sceneGroup = self.view
 
    local bgGradient = App.createBgGradient()
    sceneGroup:insert( bgGradient )
    local btn_back = Utils.createImage( nil, "Assets/Images/btn_back.png", 40, nil, 0, 0 )
    btn_back.x = Utils.getLeftInScreen() + btn_back.contentWidth
    btn_back.y = Utils.getTopInScreen() + btn_back.contentHeight
    sceneGroup:insert( btn_back )
    btn_back:addEventListener("tap", onBtnBack)

    local fontSize = 30

    local btn_resetscore = Utils.createImage( nil, "Assets/Images/btn_resetscore.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, 0 )
    btn_resetscore.y = Utils.getBottomInScreen() - btn_resetscore.contentHeight
    sceneGroup:insert( btn_resetscore )

    btn_resetscore:addEventListener("tap", onBtnReset)

    local caption = Utils.createText(nil, "SCORE BOARD", 35, display.contentCenterX, btn_back.y + fontSize * 2)
    sceneGroup:insert( caption )

    local y = caption.y + fontSize;
    for i = 1, App.getMaxLevel() do
        local btn_score = Utils.createImage( nil, "Assets/Images/btn_score.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, 0 )
        y = y + btn_score.contentHeight / 2
        if y + btn_score.contentHeight / 2 >= btn_resetscore.y then
            btn_score:removeSelf()
            break
        end
        btn_score.y = y
        btn_score.level = i
        sceneGroup:insert( btn_score )

        btn_score:addEventListener("tap", onBtnScore)

        local score = Utils.createText(nil, "", fontSize, display.contentCenterX, btn_score.y)
        score:setFillColor(unpack(App.getPrimaryTextColor()))
        sceneGroup:insert( score )

        y = y + fontSize / 2 + btn_score.contentHeight / 2

        scoreBoxs[#scoreBoxs + 1] = score
    end
end

-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        scores = {}

        for i = 1, App.getMaxLevel() do
            scores[i] = App.getPreferenceLevelScore(i)
        end
        self:render()
    elseif ( phase == "did" ) then
    end
end

function scene:render()
    for i = 1, #scoreBoxs do
        if i <= #scores then
            scoreBoxs[i].text = "LEVEL"..i.." : "..scores[i]
        else
            scoreBoxs[i].text = "LEVEL"..i.." : -"
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