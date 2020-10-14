local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")
local keys = require("keys")
local decorations = require("decorations")

-- Button configuration
local gen_button_size = dpi(12)
local gen_button_margin = dpi(6)
local gen_button_color_unfocused = beautiful.transparent
local gen_button_shape = gears.shape.circle

awful.titlebar.fallback_name = ""

-- Add a titlebar
client.connect_signal("request::titlebars", function(c)
    awful.titlebar(c, {
        font = beautiful.titlebar_font,
        position = beautiful.titlebar_position,
        size = beautiful.titlebar_size,
    }) : setup {
        {
            helpers.horizontal_pad(gen_button_margin),
            decorations.button(c, gen_button_shape, colors.color4, gen_button_color_unfocused, colors.color12, gen_button_size, gen_button_margin, "floating"),
            layout = wibox.layout.fixed.horizontal
        },
        {
            buttons = keys.titlebar_buttons,
            font = beautiful.titlebar_font,
            align = beautiful.titlebar_title_align,
            widget = awful.titlebar.widget.titlewidget(c)
        },
        {
            -- Generated buttons:w
            decorations.button(c, gen_button_shape, colors.color2, gen_button_color_unfocused, colors.color10, gen_button_size, gen_button_margin, "maximize"),
            decorations.button(c, gen_button_shape, colors.color3, gen_button_color_unfocused, colors.color11, gen_button_size, gen_button_margin, "minimize"),
            decorations.button(c, gen_button_shape, colors.color1, gen_button_color_unfocused, colors.color9, gen_button_size, gen_button_margin, "close"),

            -- Create some extra padding at the edge
            helpers.horizontal_pad(gen_button_margin),

            layout = wibox.layout.fixed.horizontal,
        },
        shape = helpers.rrect(beautiful.border_radius, true, true, false, false),
        layout = wibox.layout.align.horizontal
    }
end)
