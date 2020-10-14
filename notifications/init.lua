local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")

local notifications = {}

-- Timeouts
naughty.config.presets.low.fg = colors.active
naughty.config.presets.critical.fg = beautiful.bg
naughty.config.presets.critical.bg = "#ffaa00c0"
naughty.config.presets.critical.timeout = 10

-- >> Notify DWIM (Do What I Mean):
-- Create or update notification automagically. Requires storing the
-- notification in a variable.
-- Example usage:
--     local my_notif = notifications.notify_dwim({ title = "hello", message = "there" }, my_notif)
--     -- After a while, use this to update or recreate the notification if it is expired / dismissed
--     my_notif = notifications.notify_dwim({ title = "good", message = "bye" }, my_notif)
function notifications.notify_dwim(args, notif)
    local n = notif
    if n and not n._private.is_destroyed and not n.is_expired then
        notif.title = args.title or notif.title
        notif.message = args.message or notif.message
        notif.timeout = args.timeout or notif.timeout
    else
        n = naughty.notification(args)
    end
    return n
end

function notifications.init()
    -- Load theme
    require("notifications.theme")
end

-- Handle notification icon
-- XXX Seems unsupported
-- naughty.connect_signal("request::icon", function(n, context, hints)
--     -- Handle other contexts here
--     if context ~= "app_icon" then return end

--     -- Use XDG icon
--     local path = menubar.utils.lookup_icon(hints.app_icon) or
--     menubar.utils.lookup_icon(hints.app_icon:lower())

--     if path then
--         n.icon = path
--     end
-- end)

-- XXX Seems unsupported
-- Use XDG icon
-- naughty.connect_signal("request::action_icon", function(a, context, hints)
--     a.icon = menubar.utils.lookup_icon(hints.id)
-- end)

return notifications
