#!/usr/bin/env bash

function run {
    echo "$1"
    if ! pgrep -f $1 ;
    then
        "$@" & disown
    fi
}

run light -I
run muse-status-daemon
run rot8 -d eDP -i "ELAN0732:00 04F3:2537"
run /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
run redshift
run syncthing --no-browser
xset s 270 30
run xss-lock -n "$HOME/.config/i3/lock.sh --warn" -- $HOME/.config/i3/lock.sh -n
run picom --experimental-backends
run pulseaudio --start

xrdb -load ~/.Xresources
xrdb -load ~/.cache/wal/colors.Xresources

HELLO_LOCK_FILE=/tmp/muse-hello.lock

if [ ! -e "$HELLO_LOCK_FILE" ]; then
    canberra-gtk-play --id=desktop-login & disown
    touch "$HELLO_LOCK_FILE"
fi
