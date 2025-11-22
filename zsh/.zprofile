# $ZDOTDIR/.zprofile
# Used for executing user's commands at start, will be read when starting as a login shell.
# Typically used to autostart graphical sessions and to set session-wide environment variables.

if [[ -r /etc/os-release ]]; then
    source /etc/os-release
else
    return
fi

if { [[ "$ID" == "arch" ]] || [[ "$ID_LIKE" =~ arch ]]; } \
   && command -v hyprland >/dev/null \
   && [[ $(tty) == /dev/tty* ]]; then
    if uwsm check may-start; then
        exec uwsm start hyprland-uwsm.desktop
    else
        HYPR_SESSION_ID=""

        while read -r sid uid user seat _; do
            if [[ "$user" != "$USER" ]]; then
                continue
            fi

            stype=$(loginctl show-session "$sid" -p Type --value 2>/dev/null || echo "")
            if [[ "$stype" == "wayland" ]]; then
                HYPR_SESSION_ID="$sid"
                break
            fi
        done < <(loginctl list-sessions --no-legend)

        if [[ -n "$HYPR_SESSION_ID" ]]; then
            loginctl activate "$HYPR_SESSION_ID" 2>/dev/null || true
            exit
        fi
    fi
fi
