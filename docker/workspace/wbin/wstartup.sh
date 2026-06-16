#!/bin/bash
set -e

export DISPLAY=:1
export XDG_SESSION_TYPE=x11
#export GTK_MODULES=gail:atk-bridge
#export QT_ACCESSIBILITY=1
#export FORCE_PR_ACCESSIBILITY=1

vncserver -kill $DISPLAY 2>/dev/null || true
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null || true

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ] ; then
    eval $(dbus-launch --sh-syntax)
    export DBUS_SESSION_BUS_ADDRESS
fi

if [ -z "$DBUS_SYSTEM_BUS_ADDRESS" ] ; then
    cat <<EOF > /tmp/dbus-system.conf
<!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-Bus Bus Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
<busconfig>
  <type>system</type>
  <listen>unix:path=/tmp/dbus-system-socket</listen>
  <policy context="default">
    <allow user="*"/>
    <allow own="*"/>
    <allow send_type="method_call"/>
    <allow send_type="signal"/>
    <allow send_requested_reply="true" send_type="method_return"/>
    <allow send_requested_reply="true" send_type="error"/>
    <allow receive_type="method_call"/>
    <allow receive_type="method_return"/>
    <allow receive_type="error"/>
    <allow receive_type="signal"/>
  </policy>
</busconfig>
EOF
    dbus-daemon --config-file=/tmp/dbus-system.conf --fork
    export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/tmp/dbus-system-socket
fi

vncserver $DISPLAY -geometry $VNC_RESOLUTION -depth $VNC_COL_DEPTH -localhost no

exec gnome-session --builtin