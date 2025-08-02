# $ZDOTDIR/.zprofile
# Used for executing user's commands at start, will be read when starting as a login shell.
# Typically used to autostart graphical sessions and to set session-wide environment variables.

if [[ -r /etc/os-release ]]; then
    source /etc/os-release
else
    return
fi

if { [[ "$ID" == "arch" ]] \
    || [[ "$ID_LIKE" =~ arch ]] ; } \
    && command -v hyprland >/dev/null \
    && [[ $(tty) == /dev/tty*  ]] \
    && uwsm check may-start; then
    # Checks Passed
    exec uwsm start hyprland-uwsm.desktop
fi
