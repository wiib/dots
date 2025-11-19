set +e

dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots >/dev/null 2>&1

dms run >/dev/null 2>&1 &

wl-clip-persist --clipboard regular --reconnect-tries 0 >/dev/null 2>&1 &

wl-paste --watch cliphist store >/dev/null 2>&1 &

/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &