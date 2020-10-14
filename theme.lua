local awful = require("awful")
local gears = require("gears")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gfs = require("gears.filesystem")

local helpers = require("helpers")

local theme = {}

local bg_alpha_hex = "c0"
local unfocused_alpha = "40"

-- Set the theme font. This is the font that will be used by default in menus, bars, titlebars etc.
theme.font          = "sans 11"

theme.bg            = colors.color0 .. bg_alpha_hex
theme.bg_dark       = theme.bg
theme.bg_normal     = theme.bg
theme.bg_focus      = colors.color8 .. bg_alpha_hex
theme.bg_urgent     = "#ffaa00" .. bg_alpha_hex
theme.bg_minimize   = theme.bg

theme.fg            = colors.color15
theme.fg_normal     = theme.fg
theme.fg_unfocused  = colors.active
theme.fg_focus      = theme.fg
theme.fg_urgent     = colors.color0
theme.fg_minimize   = colors.color8 .. unfocused_alpha

theme.transparent   = "#00000000"

-- Gaps
theme.useless_gap   = dpi(8)
-- This could be used to manually determine how far away from the
-- screen edge the bars / notifications should be.
theme.screen_margin = dpi(8)

-- Borders
theme.border_width  = dpi(0)
theme.border_color = theme.bg
theme.border_normal = colors.background
theme.border_focus  = colors.background

-- Rounded corners
theme.border_radius = dpi(12)

-- Titlebars
-- (Titlebar items can be customized in titlebars.lua)
theme.titlebars_enabled = true
theme.titlebar_size = dpi(32)
theme.titlebar_title_enabled = true
theme.titlebar_font = theme.font
theme.titlebar_title_align = "center"
theme.titlebar_position = "top"
theme.titlebar_bg = theme.bg
theme.titlebar_fg_focus = theme.fg
theme.titlebar_fg_normal = theme.fg_unfocused

-- Notifications
-- ============================
-- Note: Some of these options are ignored by my custom
-- notification widget_template
-- ============================
-- Position: bottom_left, bottom_right, bottom_middle, top_left, top_right, top_middle
theme.notification_font = theme.font
theme.notification_bg = theme.bg
theme.notification_fg = theme.fg
theme.notification_border_width = theme.border_width
theme.notification_border_color = theme.border_color
theme.notification_margin = dpi(16)
theme.notification_icon_size = dpi(48)
theme.notification_max_width = dpi(512)
theme.notification_max_height = dpi(256)
theme.notification_spacing = dpi(8)
theme.notification_shape = helpers.rrect(theme.border_radius);

-- Edge snap
theme.snap_shape = gears.shape.rectangle
theme.snap_bg = colors.foreground
theme.snap_border_width = dpi(4)

-- Tag names
theme.tagnames = {
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
}

-- Widget separator
theme.separator_text = "|"
--theme.separator_text = " :: "
--theme.separator_text = " • "
-- theme.separator_text = " •• "
theme.separator_fg = colors.color8

theme.prefix_fg = colors.color8

 --There are other variable sets
 --overriding the default one when
 --defined, the sets are:
 --taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
 --tasklist_[bg|fg]_[focus|urgent]
 --titlebar_[bg|fg]_[normal|focus]
 --tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
 --mouse_finder_[color|timeout|animate_timeout|radius|factor]
 --prompt_[fg|bg|fg_cursor|bg_cursor|font]
 --hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
 --Example:
 theme.hotkeys_bg = theme.bg
 theme.hotkeys_fg = theme.fg
 theme.hotkeys_modifiers_fg = colors.color14
 theme.hotkeys_font = theme.font
 theme.hotkeys_description_font = "sans 8"
 theme.hotkeys_group_margin = dpi(16)

 --Tasklist
theme.tasklist_font = theme.font
theme.tasklist_disable_icon = false
theme.tasklist_plain_task_name = true
theme.tasklist_bg_normal = "#ff000000"
theme.tasklist_fg_normal = colors.active
theme.tasklist_bg_focus = theme.fg .. "20"
theme.tasklist_fg_focus = colors.fg
theme.tasklist_bg_minimize = colors.transparent
theme.tasklist_fg_minimize = colors.active
theme.tasklist_font_minimized = "sans italic 11"
theme.tasklist_bg_urgent = "#ffaa00"
theme.tasklist_fg_urgent = theme.bg
theme.tasklist_spacing = dpi(0)

-- Exit screen
theme.exit_screen_bg = theme.bg
theme.exit_screen_fg = colors.color7
theme.exit_screen_font = "sans 20"
theme.exit_screen_icon_size = dpi(180)

-- Prompt
theme.prompt_fg = colors.color12

-- Text Taglist (default)
theme.taglist_font = theme.font
theme.taglist_bg_focus = theme.transparent
theme.taglist_bg_occupied = theme.transparent
theme.taglist_bg_empty = colors.background
theme.taglist_bg_urgent = "#ffaa00"
theme.taglist_fg_focus = theme.fg
theme.taglist_fg_occupied = theme.fg_unfocused
theme.taglist_fg_empty = theme.transparent
theme.taglist_fg_urgent = theme.bg
theme.taglist_disable_icon = true
theme.taglist_spacing = dpi(0)

-- Variables set for theming the menu:
theme.menu_height = dpi(32)
theme.menu_width  = dpi(128)
theme.menu_bg_normal = theme.bg
theme.menu_fg_normal= colors.color7
theme.menu_bg_focus = colors.color8 .. "80"
theme.menu_fg_focus= colors.color7
theme.menu_border_width = dpi(0)
theme.menu_border_color = theme.bg

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = "/usr/share/icons/Flat-Remix-Blue-Dark"

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
