function verify_network_interfaces()
{
    if [[ "${INTERFACE_DEFAULT}" == "" ]]; then
        exception 1 "Default interface is not specified."
    fi

    if [[ "${INTERFACE_TUNNEL}" == "" ]]; then
        exception 1 "Tunnel interface is not specified."
    fi

    for interface in "${INTERFACE_DEFAULT}" "${INTERFACE_TUNNEL}"; do
        interface_setup="$(ifconfig "${interface}" 2> /dev/null || echo "")"

        if [[ "${interface_setup}" == "" ]]; then
            exception 1 "Interface ${interface} doesn't exist."
        fi

        if [[ "$(echo "${interface_setup}" | egrep '^\s+status: active$')" == "" ]]; then
            exception 1 "Interface ${interface} is shut down."
        fi
    done
}

function restart_network_interfaces()
{
    echo "Restarting network interfaces."

    ifconfig "${INTERFACE_DEFAULT}" down
    ifconfig "${INTERFACE_TUNNEL}" down
    sleep 2
    ifconfig "${INTERFACE_DEFAULT}" up
    ifconfig "${INTERFACE_TUNNEL}" up

    # TODO: create function check_network_status, which checks if interfaces are already online and connected
    #       or maybe checks netstat if default-gateway exists for specified interface.
    sleep 5
}
