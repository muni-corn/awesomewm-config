local awful = require("awful")
local beautiful = require("beautiful")
local helpers = require("helpers")
local gears = require("gears")
local wibox = require("wibox")

-- Disable popup tooltip on titlebar button hover
awful.titlebar.enable_tooltip = true

local decorations = {}

-- Helper function to be used by decoration themes to enable client rounding
function decorations.enable_rounding()
    -- Apply rounded corners to clients if needed
    if beautiful.border_radius and beautiful.border_radius > 0 then
        client.connect_signal("manage", function (c, startup)
            if not c.fullscreen and not c.maximized then
                c.shape = helpers.rrect(beautiful.border_radius)
            end
        end)

        beautiful.snap_shape = helpers.rrect(beautiful.border_radius * 2)
    else
        beautiful.snap_shape = gears.shape.rectangle
    end

    -- No rounded corners if there is only one client (thanks, u/Imtechbum :))
    screen.connect_signal("arrange", function (s)
        local only_one = #s.tiled_clients == 1
        for _, c in pairs(s.tiled_clients) do
            if only_one or c.maximized or c.fullscreen then
                c.shape = gears.shape.rectangle
            else
                c.shape = helpers.rrect(beautiful.border_radius)
            end
        end
    end)
end

local button_commands = {
    ['close'] = { fun = function(c) c:kill() end, track_property = nil } ,
    ['maximize'] = { fun = function(c) c.maximized = not c.maximized; c:raise() end, track_property = "maximized" },
    ['minimize'] = { fun = function(c) c.minimized = true end },
    ['floating'] = { fun = function(c) c.floating = not c.floating; c:raise() end, track_property = "floating" },
}

-- >> Helper functions for generating simple window buttons
-- Generates a button using an AwesomeWM widget
decorations.button = function (c, shape, color, unfocused_color, hover_color, size, margin, cmd)
    local button = wibox.widget {
        forced_height = size,
        forced_width = size,
        bg = (client.focus and c == client.focus) and color or unfocused_color,
        shape = shape,
        widget = wibox.container.background()
    }

    -- Instead of adding spacing between the buttons, we add margins
    -- around them. That way it is more forgiving to click them
    -- (especially if they are very small)
    local button_widget = wibox.widget {
        button,
        margins = margin,
        widget = wibox.container.margin(),
    }
    button_widget:buttons(gears.table.join(
            awful.button({ }, 1, function ()
                button_commands[cmd].fun(c)
            end)
        ))

    local p = button_commands[cmd].track_property
    -- Track client property if needed
    if p then
        local active_color = color
        local inactive_color = color .. "40"

        if p == "floating" then
            local tmp = active_color
            active_color = inactive_color
            inactive_color = tmp
        end

        c:connect_signal("property::"..p, function ()
            button.bg = c[p] and inactive_color or active_color
        end)
        c:connect_signal("focus", function ()
            button.bg = c[p] and inactive_color or active_color
        end)
        button_widget:connect_signal("mouse::leave", function ()
            if c == client.focus then
                button.bg = c[p] and inactive_color or active_color
            else
                button.bg = unfocused_color
            end
        end)
    else
        button_widget:connect_signal("mouse::leave", function ()
            if c == client.focus then
                button.bg = color
            else
                button.bg = unfocused_color
            end
        end)
        c:connect_signal("focus", function ()
            button.bg = color
        end)
    end
    button_widget:connect_signal("mouse::enter", function ()
        button.bg = hover_color
    end)
    c:connect_signal("unfocus", function ()
        button.bg = unfocused_color
    end)

    return button_widget
end

-- Load theme and custom decorations
function decorations.init()
    require("decorations.titlebar")
    decorations.enable_rounding()
end

return decorations
