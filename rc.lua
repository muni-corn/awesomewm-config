--[[
   ___       ___       ___       ___       ___       ___       ___
  /\  \     /\__\     /\  \     /\  \     /\  \     /\__\     /\  \
 /  \  \   / /\__\   /  \  \   /  \  \   /  \  \   /  L_L_   /  \  \
/  \ \__\ / / /\__\ /  \ \__\ /\ \ \__\ / /\ \__\ / /L \__\ /  \ \__\
\/\  /  / \  / /  / \ \ \/  / \ \ \/__/ \ \/ /  / \/_/ /  / \ \ \/  /
  / /  /   \  /  /   \ \/  /   \  /  /   \  /  /    / /  /   \ \/  /
  \/__/     \/__/     \/__/     \/__/     \/__/     \/__/     \/__/
--]]

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Import wpgtk colors
colors = require("colors")

-- Standard awesome libraries
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.autofocus")

-- Start apps
awful.spawn.with_shell(os.getenv("HOME") .. "/.config/wpg/wp_init.sh")
awful.spawn.with_shell(os.getenv("HOME") .. "/.config/awesome/autostart.sh")

-- -- {{{ Error handling
-- -- Check if awesome encountered an error during startup and fell back to
-- -- another config (This code will only ever execute for the fallback config)
-- if awesome.startup_errors then
--     naughty.notify({ preset = naughty.config.presets.critical,
--                      title = "Oops, there were errors during startup!",
--                      text = awesome.startup_errors })
-- end

-- -- Handle runtime errors after startup
-- do
--     local in_error = false
--     awesome.connect_signal("debug::error", function (err)
--         -- Make sure we don't go into an endless error loop
--         if in_error then return end
--         in_error = true

--         naughty.notify({ preset = naughty.config.presets.critical,
--                          title = "Oops, an error happened!",
--                          text = tostring(err) })
--         in_error = false
--     end)
-- end
-- -- }}}

-- {{{ Variable definitions
-- Init theme variables
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")
dpi = beautiful.xresources.apply_dpi

-- App config (See apps.lua)
terminal = "kitty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
user = {
    terminal = terminal,
    floating_terminal = terminal,
    browser = "firefox",
    file_manager = terminal.." --class files -e ranger",
    editor = terminal.." --class editor -e nvim",
    email_client = "evolution",
    music_client = "spotify",
    media_center = "kodi",
    dirs = {
        screenshots = os.getenv("HOME") .. "/Pictures/Screenshots/"
    }
}

-- Custom libraries
local keys = require("keys")
local decorations = require("decorations")
local notifications = require("notifications")
decorations.init()
notifications.init()
require("bar")
require("elemental.exit")

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.append_default_layouts {
    awful.layout.suit.tile,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
}
-- }}}

local function set_wallpaper(s)
    -- Wallpaper
    awful.spawn.easy_async_with_shell('wpg -c', function(stdout, _, __, ___)
        local wallpaper = os.getenv("HOME") .. "/.config/wpg/wallpapers/" .. (stdout:match "^%s*(.-)%s*$")

        gears.wallpaper.maximized(wallpaper, s, false)
    end)
end


-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "•" }, s, awful.layout.layouts[1])

    for _,t in ipairs(s.tags) do
        t.gap_single_client = false
    end
end)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = keys.clientkeys,
                     buttons = keys.clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Put new windows at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end

    -- don't let any clients start maximized (confusing with
    -- gap_single_client = false
    c.maximized = false

end)

client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

-- client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
-- client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
