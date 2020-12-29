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


-- {{{ Get screen width, height
function screen_width()  
    return awful.screen.focused().geometry.width
end
function screen_height()  
    return awful.screen.focused().geometry.height
end
-- }}}

-- {{{ Rules
-- Determines how floating clients should be placed
local floating_client_placement = function(c)
    -- If the layout is floating or there are no other visible
    -- clients, center client
    if awful.layout.get(mouse.screen) ~= awful.layout.suit.floating or #mouse.screen.clients == 1 then
        return awful.placement.centered(c,{honor_padding = true, honor_workarea=true})
    end

    -- Else use this placement
    local p = awful.placement.no_overlap + awful.placement.no_offscreen
    return p(c, {honor_padding = true, honor_workarea=true, margins = beautiful.useless_gap * 2})
end

local centered_client_placement = function(c)
    return gears.timer.delayed_call(function ()
        awful.placement.centered(c, {honor_padding = true, honor_workarea=true})
    end)
end

-- Rules
awful.rules.rules = {
    {
        -- All clients will match this rule.
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = keys.clientkeys,
            buttons = keys.clientbuttons,
            screen = awful.screen.focused,
            size_hints_honor = false,
            honor_workarea = true,
            honor_padding = true,
            maximized = false,
            titlebars_enabled = beautiful.titlebars_enabled,
            maximized_horizontal = false,
            maximized_vertical = false,
            placement = floating_client_placement
        },
    },

    -- Floating clients
    {
        rule_any = {
            instance = {
                "floating_terminal",
                "Devtools",
            },
            class = {
                "Gpick",
                "Lxappearance",
                "Nm-connection-editor",
                "File-roller",
                "fst",
            },
            name = {
                "Event Tester",  -- xev
                "MetaMask Notification",
            },
            role = {
                "AlarmWindow",
                "pop-up",
                "GtkFileChooserDialog",
                "conversation",
            },
            type = {
                "dialog",
            }
        },
        properties = { floating = true }
    },

    -- Centered clients
    {
        rule_any = {
            type = {
                "dialog",
            },
            class = {
                "Steam",
                "discord",
                "music",
            },
            instance = {
                "music",
            },
            role = {
                "GtkFileChooserDialog",
                "conversation",
            }
        },
        properties = { placement = centered_client_placement },
    },

    -- Titlebars OFF (explicitly)
    {
        rule_any = {
            type = {
              "splash",
              "modal"
            },
        },
        callback = function(c)
            awful.titlebar.hide(c)
        end
    },

    -- Titlebars ON (explicitly)
    {
        rule_any = {
            type = {
                "dialog",
            },
            role = {
                "conversation",
            }
        },
        callback = function(c)
            decorations.show(c)
        end
    },

    -- Visualizer
    {
        rule_any = { class = { "Visualizer" } },
        properties = {
            floating = true,
            maximized_horizontal = true,
            sticky = true,
            ontop = false,
            skip_taskbar = true,
            below = true,
            focusable = false,
            height = screen_height() * 0.40,
            opacity = 0.6,
            titlebars_enabled = false,
        },
        callback = function (c)
            awful.placement.bottom(c)
        end
    },

    -- File chooser dialog
    {
        rule_any = { role = { "GtkFileChooserDialog" } },
        properties = { floating = true, width = screen_width() * 0.5, height = screen_height() * 0.75 }
    },

    -- Pavucontrol
    {
        rule_any = { class = { "Pavucontrol" } },
        properties = { floating = true, width = screen_width() * 0.5, height = screen_height() * 0.75 }
    },

    -- Keepass
    {
        rule_any = { class = { "KeePassXC" } },
        except_any = { name = { "KeePassXC-Browser Confirm Access" }, type = { "dialog" } },
        properties = { floating = true, width = screen_width() * 0.5, height = screen_height() * 0.75, minimized = true },
    },

    -- Scratchpad
    {
        rule_any = {
            instance = {
                "scratchpad",
                "markdown_input"
            },
            class = {
                "scratchpad",
                "markdown_input"
            },
        },
        properties = {
            skip_taskbar = false,
            floating = true,
            ontop = false,
            minimized = true,
            sticky = false,
            width = screen_width() * 0.75,
            height = screen_height() * 0.75
        }
    },

    -- Music clients (usually a terminal running ncmpcpp)
    {
        rule_any = {
            class = {
                "music",
            },
            instance = {
                "music",
            },
        },
        properties = {
            floating = true,
            width = screen_width() * 0.5,
            height = screen_height() * 0.5
        },
    },

    -- Image viewers
    {
        rule_any = {
            class = {
                "feh",
                "Sxiv",
            },
        },
        properties = {
            floating = true,
            width = screen_width() * 0.75,
            height = screen_height() * 0.75
        },
        callback = function (c)
            awful.placement.centered(c, { honor_padding = true, honor_workarea = true })
        end
    },
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
