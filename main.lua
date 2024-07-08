-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local composer = require("composer")
local Utils = require("src.helper.utils")
local App = require("src.helper.app")

-- Your code here
display.setStatusBar( display.HiddenStatusBar )
-- Seed the random number generator
math.randomseed( os.time() )

local bg = App.createBgGradient()

local loadingTxt = Utils.createText(nil, "LOADING...", 35, display.contentCenterX, display.contentCenterY)

-- local function httpRequest(url, callback)
--     network.request(url, "GET", function(event)
--         if (event.isError) then
--             callback(nil)
--         else
--             callback(event.response)
--         end
--     end)
-- end

-- local function createWebView(data)
--     local webView = native.newWebView(display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight)
--     webView:request(data)
-- end

-- local function loadDataAndCreateWebView()
--     local url = "https://google.com"
--     httpRequest(url, function(data)
--         loadingTxt:removeSelf()
--         bg:removeSelf()

--         if data and #data > 100 then
--             createWebView(url)
--         else
--             composer.gotoScene( "src.scene.start", { effect="fade", time=800 } )        
--         end
--     end)
-- end

-- loadDataAndCreateWebView()
loadingTxt:removeSelf()
bg:removeSelf()
composer.gotoScene( "src.scene.start", { effect="fade", time=800 } )        
