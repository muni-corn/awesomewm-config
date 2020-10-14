local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")
local beautiful = require("beautiful")
local apps = require("apps")
local decorations = require("decorations")

local helpers = require("helpers")

local keys = {}
local hotkeys_popup = require("awful.hotkeys_popup")

-- Mod keys
superkey = "Mod4"
altkey = "Mod1"
ctrlkey = "Control"
shiftkey = "Shift"

local function enable_floating_video(c, height)
    awful.titlebar.hide(c, beautiful.titlebar_position)
    c.floating = true
    c.width = height * 16 / 9
    c.height = height
    c.sticky = true
    c.ontop = true
    awful.placement.top_right(c, { honor_workarea = true, margins = 0 })

    local disable_floating_video = function()
        if not c.floating then
            awful.titlebar.show(c, beautiful.titlebar_position)
            c.sticky = false
            c.ontop = false
        end
    end

    c:connect_signal("property::floating", disable_floating_video)
end

local app_switcher_grabber
local app_switcher_first_client

local function stop_switch_apps()
    -- Add currently focused client to history
    if client.focus then
        local app_switcher_last_client = client.focus
        awful.client.focus.history.add(app_switcher_last_client)
        -- Raise client that was focused originally
        -- Then raise last focused client
        if app_switcher_first_client and app_switcher_first_client.valid then
            app_switcher_first_client:raise()
            app_switcher_last_client:raise()
        end
    end
    -- Resume recording focus history
    awful.client.focus.history.enable_tracking()
    -- Stop and hide window_switcher
    local s = awful.screen.focused()
    awful.keygrabber.stop(app_switcher_grabber)
    s.dock.visible = false
end

local function start_switch_apps(s)
    s.dock.visible = true

    app_switcher_first_client = client.focus

    -- Stop recording focus history
    awful.client.focus.history.disable_tracking()

    -- Go to previously focused client (in the tag)
    awful.client.focus.history.previous()

    local keybinds = {
        ['Tab'] = function() awful.client.focus.byidx(1) end,
    }

    -- Start the keygrabber
    app_switcher_grabber = awful.keygrabber.run(function(_, key, event)
        if event == "release" then
            -- Hide if the modifier was released
            -- We try to match Super or Alt or Control since we do not know which keybind is
            -- used to activate the window switcher (the keybind is set by the user in keys.lua)
            if key:match("Super") or key:match("Alt") or key:match("Control") then
                stop_switch_apps()
            end
            -- Do nothing
            return
        end

        -- Run function attached to key, if it exists
        if keybinds[key] then
            keybinds[key]()
        end
    end)
end

-- {{{ Key bindings
keys.globalkeys = gears.table.join(
    -- key help
    awful.key({ superkey }, "F1", hotkeys_popup.show_help,
          {description = "show help", group = "awesome"}),
    
    -- focus next screen
    awful.key({ superkey }, "Tab",
        function()
            awful.screen.focus_relative(1)
        end,
        {description = "focus next screen", group = "screen"}),

    -- Focus client by direction (hjkl keys) {{{
    awful.key({ superkey }, "j",
        function()
            awful.client.focus.bydirection("down")
        end,
        {description = "focus down", group = "client"}),
    awful.key({ superkey }, "k",
        function()
            awful.client.focus.bydirection("up")
        end,
        {description = "focus up", group = "client"}),
    awful.key({ superkey }, "h",
        function()
            awful.client.focus.bydirection("left")
        end,
        {description = "focus left", group = "client"}),
    awful.key({ superkey }, "l",
        function()
            awful.client.focus.bydirection("right")
        end,
        {description = "focus right", group = "client"}),
    awful.key({ superkey }, "Down",
        function()
            awful.client.focus.bydirection("down")
        end,
        {description = "focus down", group = "client"}),
    awful.key({ superkey }, "Up",
        function()
            awful.client.focus.bydirection("up")
        end,
        {description = "focus up", group = "client"}),
    awful.key({ superkey }, "Left",
        function()
            awful.client.focus.bydirection("left")
        end,
        {description = "focus left", group = "client"}),
    awful.key({ superkey }, "Right",
        function()
            awful.client.focus.bydirection("right")
        end,
        {description = "focus right", group = "client"}),
    -- }}}

    -- Window switcher
    awful.key({ altkey }, "Tab",
        function ()
            start_switch_apps(awful.screen.focused())
        end,
        {description = "switch apps", group = "client"}),

    -- Restore a minimized window
    awful.key({ superkey, shiftkey }, "v",
        function ()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                client.focus = c
            end
        end,
        {description = "restore minimized", group = "client"}),

    -- Jump to urgent client or go back to the last tag
    awful.key({ superkey }, "u",
        function ()
            uc = awful.client.urgent.get()
            -- If there is no urgent client, go back to last tag
            if uc == nil then
                awful.tag.history.restore()
            else
                awful.client.urgent.jumpto()
            end
        end,
        {description = "jump to urgent client", group = "client"}),

    -- Reload Awesome
    awful.key({ superkey, shiftkey }, "r", awesome.restart,
        {description = "reload", group = "awesome"}),

    -- Quit Awesome
    -- Logout, Shutdown, Restart, Suspend, Lock
    awful.key({ superkey, ctrlkey }, "q",
        function ()
            exit_screen_show()
        end,
        {description = "leave", group = "awesome"}),

    -- Lock
    awful.key({ superkey }, "Escape",
        function ()
            awful.spawn.with_shell(os.getenv("HOME").."/.config/i3/lock.sh")
        end,
        {description = "lock", group = "awesome"}),

    -- Change wallpaper
    awful.key({ superkey, ctrlkey }, "w", function()
            awful.spawn("wpg -m")
        end,
        {description = "next wallpaper", group = "awesome"}),

    -- Layout options {{{
    -- increase/decrease master clients (mnemonic by direction)
    awful.key({ superkey, ctrlkey }, "j",   
        function () 
            awful.tag.incnmaster( 1, nil, true) 
        end,
        {description = "increase the number of master clients", group = "layout"}),
    awful.key({ superkey, ctrlkey }, "k",   
        function () 
            awful.tag.incnmaster(-1, nil, true) 
        end,
        {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ superkey, ctrlkey }, "Down",   
        function () 
            awful.tag.incnmaster( 1, nil, true) 
        end,
        {description = "increase the number of master clients", group = "layout"}),
    awful.key({ superkey, ctrlkey }, "Up",   
        function () 
            awful.tag.incnmaster(-1, nil, true) 
        end,
        {description = "decrease the number of master clients", group = "layout"}),
    -- Number of columns
    awful.key({ superkey, ctrlkey }, "l",   
        function () 
            awful.tag.incncol( 1, nil, true)
        end,
        {description = "increase the number of columns", group = "layout"}),
    awful.key({ superkey, ctrlkey }, "h",   
        function () 
            awful.tag.incncol( -1, nil, true)
        end,
        {description = "decrease the number of columns", group = "layout"}),
    awful.key({ superkey, ctrlkey }, "Left",   
        function () 
            awful.tag.incncol( 1, nil, true)
        end,
        {description = "increase the number of columns", group = "layout"}),
    awful.key({ superkey, ctrlkey }, "Right",   
        function () 
            awful.tag.incncol( -1, nil, true)
        end,
        {description = "decrease the number of columns", group = "layout"}),
    --}}}

    -- App shortcuts {{{
    -- Spawn terminal
    awful.key({ superkey }, "Return", function () awful.spawn(user.terminal) end,
        {description = "open a terminal", group = "apps"}),

    -- Spawn file manager
    awful.key({ superkey }, "e", apps.file_manager,
        {description = "file manager", group = "apps"}),

    -- Spawn music client
    awful.key({ superkey }, "b", apps.music,
        {description = "music client", group = "apps"}),

    -- Quick note
    awful.key({ superkey, ctrlkey }, "n", apps.quick_note,
        {description = "quick note", group = "apps"}),

    -- Browser
    awful.key({ superkey }, "w", apps.browser,
        {description = "browser", group = "apps"}),

    -- Editor
    awful.key({ superkey }, "n", apps.editor,
        {description = "editor", group = "apps"}),

    -- htop
    awful.key({ superkey }, "p", apps.process_monitor,
        {description = "process monitor", group = "apps"}),

    -- ponies
    awful.key({ superkey, shiftkey }, "p", apps.ponies,
        {description = "ponies", group = "apps"}),

    -- redshift toggle
    awful.key({ superkey, ctrlkey }, "r", apps.toggle_redshift,
        {description = "toggle redshift", group = "apps"}),

    -- launch qalc in terminal
    awful.key({ superkey }, "c", apps.calculator,
        {description = "calculator", group = "apps"}),

    -- pavucontrol
    awful.key({ superkey, ctrlkey }, "p", apps.pavucontrol,
        {description = "volume control", group = "apps"}),

    -- notebook
    awful.key({ superkey, shiftkey }, "n", apps.notebook,
        {description = "open notebook", group = "apps"}),

    -- bored
    awful.key({ superkey, shiftkey }, "b", apps.bored,
        {description = "boredom remedies", group = "apps"}),

    -- email
    awful.key({ superkey }, "m", apps.email,
        {description = "email", group = "apps"}),

    -- media
    awful.key({ superkey, shiftkey }, "m", apps.media_center,
        {description = "media center", group = "apps"}),
    -- }}}

    -- Rofi shortcuts {{{
    awful.key({ superkey }, "a",
        function()
            awful.spawn.with_shell("rofi -show drun -config ~/.config/rofi/apps_config.rasi")
        end,
        {description = "launch an app", group = "apps"}),
    awful.key({ superkey, ctrlkey }, "e", 
        function() 
            awful.spawn.with_shell("rofi -show emoji -modi emoji")
        end, 
        {description = "open emoji menu", group = "apps"}),
    -- }}}

    -- Dismiss notifications and elements that connect to the dismiss signal
    awful.key( { ctrlkey }, "Escape",
        function()
            awesome.emit_signal("elemental::dismiss")
            naughty.destroy_all_notifications()
        end,
        {description = "dismiss all notifications", group = "notifications"}),

    -- Brightness {{{
    awful.key( { }, "XF86MonBrightnessDown",
        function()
            awful.spawn("light -U 5", false)
            awful.spawn("muse-status update brightness", false)
        end),
    awful.key( { }, "XF86MonBrightnessUp",
        function()
            awful.spawn("light -A 5", false)
            awful.spawn("muse-status update brightness", false)
        end),
    -- }}}

    -- Volume {{{
    awful.key( { }, "XF86AudioMute",
        function()
            helpers.volume_mute_toggle()
        end),
    awful.key( { }, "XF86AudioLowerVolume",
        function()
            helpers.volume_down()
        end),
    awful.key( { }, "XF86AudioRaiseVolume",
        function()
            helpers.volume_up()
        end),
    -- }}}

    -- Screenshots {{{
    awful.key( { superkey }, "Print", function() apps.screenshot("full") end,
        {description = "take screenshot", group = "screenshots"}),
    awful.key( { superkey, altkey }, "Print", function() apps.screenshot("full-copy") end,
        {description = "copy full screenshot to clipboard", group = "screenshots"}),
    awful.key( { superkey, ctrlkey }, "Print", function() apps.screenshot("selection") end,
        {description = "take area screenshot", group = "screenshots"}),
    awful.key( { superkey, ctrlkey, altkey }, "Print", function() apps.screenshot("clipboard") end,
        {description = "copy area to clipboard", group = "screenshots"}),
    awful.key( { ctrlkey, altkey }, "Print", function() apps.screenshot("browse") end,
        {description = "browse screenshots", group = "screenshots"}),
    awful.key( { ctrlkey }, "Print", function() apps.screenshot("gimp") end,
        {description = "edit most recent screenshot with gimp", group = "screenshots"}),
    -- }}}

    -- Media keys
    awful.key({ }, "XF86AudioPlay", function() awful.spawn.with_shell("playerctl play-pause || mpc toggle") end),
    awful.key({ }, "XF86AudioNext", function() awful.spawn.with_shell("playerctl next || mpc next") end),
    awful.key({ }, "XF86AudioPrev", function() awful.spawn.with_shell("playerctl previous || mpc cdprev") end),


    -- Layouts {{{
    -- Max layout
    -- Single tap: Set max layout
    -- Double tap: Also disable floating for ALL visible clients in the tag
    awful.key({ superkey }, "y",
        function()
            awful.layout.set(awful.layout.suit.max)
            helpers.single_double_tap(
                nil,
                function()
                    local clients = awful.screen.focused().clients
                    for _, c in pairs(clients) do
                        c.floating = false
                    end
                end)
        end,
        {description = "set max layout", group = "tag"}),

    -- Tiling
    -- Single tap: Set tiled layout
    -- Double tap: Also disable floating for ALL visible clients in the tag
    awful.key({ superkey }, "t",
        function()
            awful.layout.set(awful.layout.suit.tile)
            helpers.single_double_tap(
                nil,
                function()
                    local clients = awful.screen.focused().clients
                    for _, c in pairs(clients) do
                        c.floating = false
                    end
                end)
        end,
        {description = "set tiled layout", group = "tag"})
    -- }}}
)

keys.clientkeys = gears.table.join(
    -- Resize windows {{{
    awful.key({ superkey, altkey }, "Down", function (c)
        helpers.resize_dwim(client.focus, "down")
    end),
    awful.key({ superkey, altkey }, "Up", function (c)
        helpers.resize_dwim(client.focus, "up")
    end),
    awful.key({ superkey, altkey }, "Left", function (c)
        helpers.resize_dwim(client.focus, "left")
    end),
    awful.key({ superkey, altkey }, "Right", function (c)
        helpers.resize_dwim(client.focus, "right")
    end),
    awful.key({ superkey, altkey }, "j", function (c)
        helpers.resize_dwim(client.focus, "down")
    end),
    awful.key({ superkey, altkey }, "k", function (c)
        helpers.resize_dwim(client.focus, "up")
    end),
    awful.key({ superkey, altkey }, "h", function (c)
        helpers.resize_dwim(client.focus, "left")
    end),
    awful.key({ superkey, altkey }, "l", function (c)
        helpers.resize_dwim(client.focus, "right")
    end),
    -- }}}

    -- Move windows {{{
    -- by direction
    awful.key({ superkey, shiftkey }, "Down", function (c)
        helpers.move_client_dwim(c, "down")
    end),
    awful.key({ superkey, shiftkey }, "Up", function (c)
        helpers.move_client_dwim(c, "up")
    end),
    awful.key({ superkey, shiftkey }, "Left", function (c)
        helpers.move_client_dwim(c, "left")
    end),
    awful.key({ superkey, shiftkey }, "Right", function (c)
        helpers.move_client_dwim(c, "right")
    end),
    awful.key({ superkey, shiftkey }, "j", function (c)
        helpers.move_client_dwim(c, "down")
    end),
    awful.key({ superkey, shiftkey }, "k", function (c)
        helpers.move_client_dwim(c, "up")
    end),
    awful.key({ superkey, shiftkey }, "h", function (c)
        helpers.move_client_dwim(c, "left")
    end),
    awful.key({ superkey, shiftkey }, "l", function (c)
        helpers.move_client_dwim(c, "right")
    end),

    -- to next screen
    awful.key({ superkey, shiftkey }, "Tab",
        function (c)
            c:move_to_screen()
        end,
        {description = "move client to next screen", group = "client"}),
    -- }}}

    -- Views {{{
    -- Toggle fullscreen
    awful.key({ superkey }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),

    -- Floating video
    awful.key({ superkey }, "i", function (c)
        enable_floating_video(c, 200)
    end, {description = "floating video view", group = "media"}),

    -- Big floating video
    awful.key({ superkey, shiftkey }, "i", function (c)
        enable_floating_video(c, 400)
    end, {description = "big floating video view", group = "media"}),
    -- }}}

    -- Closing windows {{{
    -- Close single
    awful.key({ superkey }, "q", function (c) c:kill() end,
        {description = "close", group = "client"}),

    -- Close all in tag
    awful.key({ superkey, shiftkey }, "q",
        function ()
            local clients = awful.screen.focused().clients
            for _, c in pairs(clients) do
                c:kill()
            end
        end,
        {description = "close all in view", group = "client"}
    ),
    -- }}}

    -- Toggle floating
    awful.key({ superkey }, "s",
        function(c)
            local layout_is_floating = (awful.layout.get(mouse.screen) == awful.layout.suit.floating)
            if not layout_is_floating then
                awful.client.floating.toggle()
            end
        end,
        {description = "toggle floating", group = "client"}),

    -- Set master
    awful.key({ superkey, ctrlkey }, "Return", function (c) c:swap(awful.client.getmaster()) end,
        {description = "move to master", group = "client"}),

    -- On top/sticky {{{
    -- On top
    awful.key({ superkey, ctrlkey }, "x", function (c) c.ontop = not c.ontop end,
        {description = "toggle keep on top", group = "client"}),
    -- Sticky
    awful.key({ superkey }, "x", function (c) c.sticky = not c.sticky end,
        {description = "toggle sticky", group = "client"}),
    -- }}}

    -- Minimizing/maximizing {{{
    -- Minimize
    awful.key({ superkey }, "v",
        function (c)
            c.minimized = true
        end,
        {description = "minimize", group = "client"}),
    -- Maximize
    awful.key({ superkey, ctrlkey }, "m",
        function (c)
            c.maximized = not c.maximized
        end,
        {description = "toggle maximize", group = "client"})
    -- }}}
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
local ntags = 10
for i = 1, ntags do
    keys.globalkeys = gears.table.join(keys.globalkeys,
        -- View tag only.
        awful.key({ superkey }, "#" .. i + 9,
            function ()
                -- Tag back and forth
                helpers.tag_back_and_forth(i)

                -- Simple tag view
                -- local tag = mouse.screen.tags[i]
                -- if tag then
                -- tag:view_only()
                -- end
            end,
            {description = "view tag", group = "tag"}),
        -- Toggle tag display.
        awful.key({ superkey, ctrlkey }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            {description = "toggle tag", group = "tag"}),

        -- Move client to tag.
        awful.key({ superkey, shiftkey }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            {description = "move focused client to tag", group = "tag"}),

        -- Move all visible clients to tag and focus that tag
        awful.key({ superkey, altkey }, "#" .. i + 9,
            function ()
                local tag = client.focus.screen.tags[i]
                local clients = awful.screen.focused().clients
                if tag then
                    for _, c in pairs(clients) do
                        c:move_to_tag(tag)
                    end
                    tag:view_only()
                end
            end,
            {description = "move all visible clients to tag", group = "tag"})
    )
end

-- Mouse buttons on the client (whole window, not just titlebar)
keys.clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c end),
    awful.button({ superkey }, 1, awful.mouse.client.move),
    awful.button({ superkey }, 3, function(c)
        client.focus = c
        awful.mouse.client.resize(c)
    end),
    awful.button({ superkey, altkey }, 1, function(c)
        client.focus = c
        awful.mouse.client.resize(c)
    end)
)

-- Mouse buttons on the tasklist
-- Use 'Any' modifier so that the same buttons can be used in the floating
-- tasklist displayed by the window switcher while the modkey is pressed
keys.tasklist_buttons = gears.table.join(
    -- Left click moves to the tag to focus the client
    awful.button({ 'Any' }, 1,
        function (c)
            if c == client.focus then
                c.minimized = true
            else
                c:jump_to()
            end
        end),

    -- Middle mouse button closes the client
    awful.button({ 'Any' }, 2, nil, function (c) c:kill() end),

    -- Right click moves the client to the current tag and raises it
    awful.button({ 'Any' }, 3, function (c) 
        c:move_to_tag(awful.screen.focused().selected_tag) 
        c:jump_to()
    end)
)

-- Mouse buttons on a tag of the taglist widget
keys.taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t)
        helpers.tag_back_and_forth(t.index)
    end),
    awful.button({ shiftkey }, 3, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end)
)


-- Mouse buttons on the primary titlebar of the window
keys.titlebar_buttons = gears.table.join(
    -- Left button - move
    awful.button({ }, 1, function()
        local c = mouse.object_under_pointer()
        client.focus = c
        awful.mouse.client.move(c)
    end)
)

-- }}}

-- Set root (desktop) keys
root.keys(keys.globalkeys)

return keys
