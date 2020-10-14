local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")

local weather_temperature_symbol
if user.weather_units == "metric" then
    weather_temperature_symbol = "°C"
elseif user.weather_units == "imperial" then
    weather_temperature_symbol = "°F"
end

-- Text icons
-- 'Material Design Icons' font
-- local sun_icon = "\u{}"
-- local moon_icon = "\u{}"
-- local dcloud_icon = "\u{}"
-- local ncloud_icon = "\u{}"
-- local cloud_icon = "\u{}"
-- local rain_icon = "\u{}"
-- local storm_icon = "\u{}"
-- local snow_icon = "\u{}"
-- local mist_icon = "\u{}"
-- local whatever_icon = "\u{}"

-- 'Material Design Icons' font (filled variant)
local sun_icon = "\u{F0599}"
local moon_icon = "\u{F0594}"
local dcloud_icon = "\u{F0595}"
local ncloud_icon = "\u{F0F31}"
local cloud_icon = "\u{F0590}"
local rain_icon = "\u{F0596}"
local storm_icon = "\u{F0593}"
local snow_icon = "\u{F0598}"
local mist_icon = "\u{F0591}"
local whatever_icon = "\u{F0595}"

local weather_description = wibox.widget{
    -- text = "Weather unavailable",
    text = "Loading weather...",
    -- align  = 'center',
    valign = 'center',
    -- font = "sans 14",
    widget = wibox.widget.textbox
}

local weather_icon = wibox.widget{
    text = whatever_icon,
    -- align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

local weather_temperature = wibox.widget{
    text = "  ",
    -- align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

local weather = wibox.widget{
    weather_icon,
    weather_description,
    weather_temperature,
    spacing = dpi(8),
    layout = wibox.layout.fixed.horizontal
}

local weather_icons = {
    ["01d"] = { icon = sun_icon, color = colors.color3 },
    ["01n"] = { icon = moon_icon, color = colors.color4 },
    ["02d"] = { icon = dcloud_icon, color = colors.color3 },
    ["02n"] = { icon = ncloud_icon, color = colors.color6 },
    ["03d"] = { icon = cloud_icon, color = colors.color1 },
    ["03n"] = { icon = cloud_icon, color = colors.color1 },
    ["04d"] = { icon = cloud_icon, color = colors.color1 },
    ["04n"] = { icon = cloud_icon, color = colors.color1 },
    ["09d"] = { icon = rain_icon, color = colors.color4 },
    ["09n"] = { icon = rain_icon, color = colors.color4 },
    ["10d"] = { icon = rain_icon, color = colors.color4 },
    ["10n"] = { icon = rain_icon, color = colors.color4 },
    ["11d"] = { icon = storm_icon, color = colors.color1 },
    ["11n"] = { icon = storm_icon, color = colors.color1 },
    ["13d"] = { icon = snow_icon, color = colors.color6 },
    ["13n"] = { icon = snow_icon, color = colors.color6 },
    ["40d"] = { icon = mist_icon, color = colors.color5 },
    ["40n"] = { icon = mist_icon, color = colors.color5 },
    ["50d"] = { icon = mist_icon, color = colors.color5 },
    ["50n"] = { icon = mist_icon, color = colors.color5 },
    ["_"] = { icon = whatever_icon, color = colors.color2 },
}

awesome.connect_signal("evil::weather", function(temperature, description, icon_code)
    local icon
    local color
    if weather_icons[icon_code] then
        icon = weather_icons[icon_code].icon
        color = weather_icons[icon_code].color
    else
        icon = weather_icons['_'].icon
        color = weather_icons['_'].color
    end

    weather_icon.markup = helpers.colorize_text(icon, color)
    weather_description.markup = description
    weather_temperature.markup = temperature
    -- weather_temperature.markup = helpers.colorize_text(tostring(temperature)..weather_temperature_symbol, color)
end)

return weather
