local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local apps = require("apps")

local helpers = require("helpers")

local hours_minutes = wibox.widget.textclock("<span color='" .. colors.color15 .. "'>%-I:%M %P</span>")

local time = {
    {
        font = "sans 44",
        align = "center",
        valign = "top",
        fg_color = colors.color15,
        widget = hours_minutes
    },
    spacing = dpi(20),
    layout = wibox.layout.fixed.horizontal
}

-- Day of the week (dotw)
local dotw = require("noodle.day_of_the_week")
local day_of_the_week = wibox.widget {
    nil,
    dotw,
    expand = "none",
    layout = wibox.layout.align.horizontal
}

local search_icon = wibox.widget {
    font = "Material Design Icons 10",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox()
}

-- Create the calendar_drawer
calendar_drawer = wibox({visible = false, ontop = true, screen = screen.primary})
calendar_drawer.fg = beautiful.calendar_drawer_fg or beautiful.wibar_fg or "#FFFFFF"
calendar_drawer.opacity = beautiful.calendar_drawer_opacity or 1
calendar_drawer.width = dpi(384)
calendar_drawer.height = dpi(256)
calendar_drawer.shape = helpers.rrect(beautiful.border_radius)
awful.placement.bottom_right(calendar_drawer, { margins = dpi(8) })

calendar_drawer:buttons(gears.table.join(
    -- Middle click - Hide calendar_drawer
    awful.button({ }, 2, function ()
        calendar_drawer_hide()
    end)
))

calendar_drawer_show = function()
    calendar_drawer.visible = true
end

calendar_drawer_hide = function()
    -- Do not hide it if prompt is active
    if not prompt_is_active or not prompt_is_active() then
        calendar_drawer.visible = false
    end
end

-- Show calendar drawer when mouse enters corner
local calendar_drawer_activator = wibox({width = 1, height = 1, visible = true, ontop = false, opacity = 0, below = true, screen = screen.primary})
awful.placement.bottom_right(calendar_drawer_activator)
calendar_drawer_activator:connect_signal("mouse::enter", function ()
    calendar_drawer.visible = true
end)

-- Hide calendar_drawer when mouse leaves
calendar_drawer:connect_signal("mouse::leave", function ()
    calendar_drawer_hide()
end)


-- Item placement
calendar_drawer:setup {
    {
        {
            helpers.vertical_pad(dpi(32)),
            {
                nil,
                {
                    time,
                    spacing = dpi(12),
                    layout = wibox.layout.fixed.horizontal
                },
                expand = "none",
                layout = wibox.layout.align.horizontal
            },
            helpers.vertical_pad(dpi(24)),
            day_of_the_week,
            helpers.vertical_pad(dpi(24)),
            {
                nil,
                cute_battery_face,
                expand = "none",
                layout = wibox.layout.align.horizontal,
            },
            helpers.vertical_pad(dpi(30)),
            layout = wibox.layout.fixed.vertical
        },
        layout = wibox.layout.fixed.vertical
    },
    shape = helpers.rect,
    bg = beautiful.calendar_drawer_bg,
    widget = wibox.container.background
}
