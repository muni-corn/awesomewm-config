-- TODO: The functions that create and update the buttons should be decoupled
-- from the dock logic. This will make it easy to create new dock themes.
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local helpers = require("helpers")
local beautiful = require("beautiful")
local apps = require("apps")
local cairo = require("lgi").cairo
local keys = require("keys")

local visible_apps = awful.widget.tasklist {
    screen = screen[1],
    filter = function(c) return not c.minimized end,
    buttons = keys.tasklist_buttons,
    style = {
        shape = gears.shape.rounded_rect,
    },
    layout = {
        spacing = dpi(16),
        forced_num_cols = 3,
        homogeneous = true,
        layout = wibox.layout.grid.vertical
    },
    widget_template = {
        {
            {
                id = 'clienticon',
                widget = awful.widget.clienticon,
                forced_width = dpi(48),
                forced_height = dpi(48),
            },
            widget = wibox.container.margin,
            margins = dpi(8),
        },
        id = "background_role",
        widget = wibox.container.background,
        shape = helpers.rrect(beautiful.border_radius),
        create_callback = function(self, c, index, objects)
            self:get_children_by_id('clienticon')[1].client = c
        end
    },
}

local invisible_apps = awful.widget.tasklist {
    screen = screen[1],
    filter = function(c) return c.minimized end,
    buttons = keys.tasklist_buttons,
    style = {
        shape = gears.shape.rounded_rect,
    },
    layout = {
        spacing = dpi(16),
        forced_num_cols = 3,
        homogeneous = true,
        layout = wibox.layout.grid.vertical
    },
    widget_template = {
        {
            {
                id     = 'clienticon',
                widget = awful.widget.clienticon,
                forced_width = dpi(48),
                forced_height = dpi(48),
            },
            widget = wibox.container.margin,
            margins = dpi(8),
        },
        id = "background_role",
        widget = wibox.container.background,
        shape = helpers.rrect(beautiful.border_radius),
        opacity = 0.5,
        create_callback = function(self, c, index, objects)
            self:get_children_by_id('clienticon')[1].client = c
        end
    },
}

app_drawer = wibox.widget({
    {
        visible_apps,
        invisible_apps,
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(32),
        spacing_widget = wibox.widget.separator {
            thickness = dpi(2),
            color = colors.inactive,
            opacity = 0.5,
            orientation = 'horizontal',
            span_ratio = 0.75,
        }
    },
    margins = dpi(16),
    widget = wibox.container.margin,
    bg       = beautiful.bg,
})

return app_drawer
