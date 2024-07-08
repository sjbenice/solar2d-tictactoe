local Utils = require("src.helper.utils")
-- Define a module for utility functions
local App = {}

function App.getMaxLevel()
    return 4
end

function App.setPreferenceMusic(isOn)
    Utils.setPreferenceBoolean("music", isOn)
end

function App.setPreferenceEffect(isOn)
    Utils.setPreferenceBoolean("effect", isOn)
end

function App.setPreferenceVibro(isOn)
    Utils.setPreferenceBoolean("vibro", isOn)
end

function App.getPreferenceMusic()
    return Utils.getPreferenceBoolean( "music", true)
end

function App.getPreferenceEffect()
    return Utils.getPreferenceBoolean( "effect", true)
end

function App.getPreferenceVibro()
    return Utils.getPreferenceBoolean( "vibro", true)
end

function App.getPreferenceLevelScore(level)
    return Utils.getPreferenceNumber( "level"..level, 0)
end

function App.setPreferenceLevelScore(level, value)
    Utils.setPreferenceNumber("level"..level, value)
end

function App.getPreferenceLevel(level)
    return Utils.getPreferenceNumber( "level", 0)
end

function App.setPreferenceLevel(value)
    Utils.setPreferenceNumber("level", value)
end

function App.getPrimaryTextColor()
    return { 1, 0.76, 0.5 }
end

function App.createBgGradient()
    local bg_gradient = display.newRect( display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight );
    bg_gradient:setFillColor( { type="gradient", color1={0.855,0.12,0.16}, color2={0.95,0.47,0.15}, direction="down" } )
    return bg_gradient
end


-- Return the module
return App
