#!/bin/bash
### every exit != 0 fails the script
set -e

### correct forwarding of shutdown signal
cleanup() {
    kill -s SIGTERM $!
    exit 0
}
trap cleanup SIGINT SIGTERM

### resolve_vnc_connection
VNC_IP=$(hostname -i)

### report the user in any case
echo "Script: $0"
id

### change vnc password
### first entry is control, second is view (if only one is valid for both)
mkdir -p "${HOME}/.vnc"
PASSWD_PATH="${HOME}/.vnc/passwd"

if [[ "${VNC_VIEW_ONLY}" == "true" ]]; then
    echo "Start VNC server in view only mode"
    ### create random pw to prevent access
    echo $(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20) | vncpasswd -f >"${PASSWD_PATH}"
fi

echo "${VNC_PW}" | vncpasswd -f >>"${PASSWD_PATH}"
chmod 600 "${PASSWD_PATH}"

XSTARTUP_FILE="${HOME}/.vnc/xstartup"
if [[ ! -f "${XSTARTUP_FILE}" ]]; then
    echo
    echo "Preparing VNC server configuration files ..."
    vncserver "${DISPLAY}"
    vncserver -kill "${DISPLAY}"
    cp "${XSTARTUP_FILE}" "${XSTARTUP_FILE}.old"
    echo "Replacing default startup script ${XSTARTUP_FILE}"
    cat <<'EOF' >"${XSTARTUP_FILE}"
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
startxfce4 &
EOF
fi

echo "Starting VNC server ..."
echo "... remove old VNC locks to be a reattachable container"
vncserver -kill "${DISPLAY}" &>"${STARTUPDIR}/vnc_startup.log" ||
    rm -rfv /tmp/.X*-lock /tmp/.X11-unix &>"${STARTUPDIR}/vnc_startup.log" ||
    echo "... no locks present"

echo "... VNC params: VNC_COL_DEPTH=${VNC_COL_DEPTH}, VNC_RESOLUTION=${VNC_RESOLUTION}"
echo "... VNC params: VNC_BLACKLIST_TIMEOUT=${VNC_BLACKLIST_TIMEOUT}, VNC_BLACKLIST_THRESHOLD=${VNC_BLACKLIST_THRESHOLD}"
vncserver "${DISPLAY}" -depth "${VNC_COL_DEPTH}" -geometry "${VNC_RESOLUTION}" \
    -BlacklistTimeout "${VNC_BLACKLIST_TIMEOUT}" \
    -BlacklistThreshold "${VNC_BLACKLIST_THRESHOLD}" &>"${STARTUPDIR}/vnc_startup.log"

### log connect options
echo "... VNC server started on display ${DISPLAY}"
echo "Connect via VNC viewer with ${VNC_IP}:${VNC_PORT}"
