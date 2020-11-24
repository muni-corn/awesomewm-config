local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
local beautiful = require("beautiful")
local helpers = require("helpers")
local notifications = require("notifications")

local apps = {}

apps.browser = function ()
    awful.spawn(user.browser)
end
apps.file_manager = function ()
    awful.spawn(user.file_manager)
end
apps.email = function ()
    helpers.run_or_focus({instance = 'email'}, false, user.email_client)
end
apps.gimp = function ()
    helpers.run_or_focus({class = 'Gimp'}, false, "gimp")
end
apps.calculator = function ()
    helpers.run_or_focus({instance = 'qalc'}, true, user.terminal.." --class qalc -e qalc")
end
apps.pavucontrol = function ()
    helpers.run_or_focus({class = 'Pavucontrol'}, true, "pavucontrol")
end
apps.editor = function ()
    awful.spawn.with_shell(user.editor)
end
apps.notebook = function()
    awful.spawn.with_shell(user.terminal.." --class notebook -T 'Notebook' -e ranger "..os.getenv("HOME").."/Notebook")
end
apps.bored = function()
    awful.spawn.with_shell(user.terminal.." --class bored -T 'YOU PRESSED THE BORED BUTTON' -e nvim "..os.getenv("HOME").."/Notebook/bored.md")
end
apps.media_center = function()
    helpers.run_or_focus({instance = 'email'}, true, user.media_center)
end

-- Toggles
apps.toggle_picom = function ()
    awful.spawn.with_shell(os.getenv("HOME").."/.config/toggle_picom.sh")
end
apps.toggle_gammastep = function ()
    awful.spawn.with_shell(os.getenv("HOME").."/.config/toggle_gammastep.sh")
end

apps.record_screen = function ()
    -- TODO
end

apps.music = function ()
    helpers.run_or_focus({instance = "music"}, false, user.music_client)
end

apps.ponies = function ()
    helpers.run_or_focus({instance = 'ponies'}, true, user.file_manager.." "..os.getenv("HOME")..[[/Videos/tv/My\ Little\ Pony:\ Friendship\ Is\ Magic\ \(2010\)]])
end

apps.process_monitor = function ()
    helpers.run_or_focus({instance = 'htop'}, false, user.terminal.." --class htop -e htop")
end

apps.temperature_monitor = function ()
    helpers.run_or_focus({class = 'sensors'}, false, user.terminal.." --class sensors -e watch sensors")
end

apps.battery_monitor = function ()
    helpers.run_or_focus({class = 'battop'}, false, user.terminal.." --class battop -e battop")
end

apps.quick_note = function ()
    awful.spawn.with_shell(user.terminal.." --class quick_note -T 'Quick note' -e nvim "..os.getenv("HOME").."/Notebook/new-"..os.date("%Y%m%d-%H%M%S")..".md")
end

-- Scratchpad terminal with tmux (see bin/scratchpad)
apps.scratchpad = function()
    helpers.scratchpad({instance = "scratchpad"}, "scratchpad", nil)
end

-- Screenshots
local capture_notif = nil
local screenshot_notification_app_name = "screenshot"
function apps.screenshot(action, delay)
    -- Read-only actions
    if action == "browse" then
        awful.spawn.with_shell("cd "..user.dirs.screenshots.." && sxiv (ls -t)")
        return
    elseif action == "gimp" then
        awful.spawn.with_shell("cd "..user.dirs.screenshots.." && gimp (ls -t | head -n1)")
        naughty.notify({ text = "Opening last screenshot for editing", app_name = screenshot_notification_app_name})
        return
    end

    -- Screenshot capturing actions
    local cmd
    local timestamp = os.date("%Y%m%d-%H%M%S")
    local filename = user.dirs.screenshots..timestamp..".png"
    local maim_args = "-u -b 3 -m 5"

    local prefix
    if delay then
        prefix = "sleep "..tostring(delay).." && "
    else
        prefix = ""
    end

    -- Configure action buttons for the notification
    local screenshot_open = naughty.action { name = "Open" }
    local screenshot_copy = naughty.action { name = "Copy" }
    local screenshot_edit = naughty.action { name = "Edit" }
    local screenshot_delete = naughty.action { name = "Delete" }
    screenshot_open:connect_signal('invoked', function()
        awful.spawn.with_shell("cd "..user.dirs.screenshots.." && sxiv $(ls -t)")
    end)
    screenshot_copy:connect_signal('invoked', function()
        awful.spawn.with_shell("xclip -selection clipboard -t image/png "..filename.." &>/dev/null")
    end)
    screenshot_edit:connect_signal('invoked', function()
        awful.spawn.with_shell("gimp "..filename.." >/dev/null")
    end)
    screenshot_delete:connect_signal('invoked', function()
        awful.spawn.with_shell("rm "..filename)
    end)

    if action == "full" then
        cmd = prefix.."maim "..maim_args.." "..filename
        awful.spawn.easy_async_with_shell(cmd, function()
            naughty.notify({
                title = "Screenshot saved",
                text = "Your screenshot was saved as "..filename,
                actions = { 
                    screenshot_open, 
                    screenshot_copy, 
                    screenshot_edit, 
                    screenshot_delete 
                },
                app_name = screenshot_notification_app_name,
            })
        end)
    elseif action == "full-copy" then
        cmd = "maim "..maim_args.." /tmp/maim_clipboard && xclip -selection clipboard -t image/png /tmp/maim_clipboard &>/dev/null && rm /tmp/maim_clipboard"
        awful.spawn.easy_async_with_shell(cmd, function(_, __, ___, exit_code)
            if exit_code == 0 then
                capture_notif = notifications.notify_dwim({ title = "Screenshot copied to clipboard", text = "The entire screen was copied.", app_name = screenshot_notification_app_name }, capture_notif)
            else
                naughty.destroy(capture_notif)
            end
        end)
    elseif action == "selection" then
        cmd = "maim "..maim_args.." -s "..filename
        capture_notif = naughty.notify({ title = "Selection screenshot started", text = "Select an area to capture.", timeout = 2, app_name = screenshot_notification_app_name })
        awful.spawn.easy_async_with_shell(cmd, function(_, __, ___, exit_code)
            naughty.destroy(capture_notif)
            if exit_code == 0 then
                naughty.notify({
                    title = "Selection screenshot saved",
                    text = "Your screenshot was saved as "..filename,
                    actions = { screenshot_open, screenshot_copy, screenshot_edit, screenshot_delete },
                    app_name = screenshot_notification_app_name,
                })
            end
        end)
    elseif action == "clipboard" then
        capture_notif = naughty.notify({ title = "Selection screenshot started", text = "Select an area of your screen to copy." })
        cmd = "maim "..maim_args.." -s /tmp/maim_clipboard && xclip -selection clipboard -t image/png /tmp/maim_clipboard &>/dev/null && rm /tmp/maim_clipboard"
        awful.spawn.easy_async_with_shell(cmd, function(_, __, ___, exit_code)
            if exit_code == 0 then
                capture_notif = notifications.notify_dwim({ title = "Selection screenshot copied", text = "Your selection was copied.", app_name = screenshot_notification_app_name }, capture_notif)
            else
                naughty.destroy(capture_notif)
            end
        end)
    end
end


return apps
