function verify_network_interfaces()
{
    if [[ "${INTERFACE_DEFAULT}" == "" ]]; then
        exception 1 "Default interface is not specified."
    fi

    if [[ "${INTERFACE_TUNNEL}" == "" ]]; then
        exception 1 "Tunnel interface is not specified."
    fi

    for interface_name in "${INTERFACE_DEFAULT}" "${INTERFACE_TUNNEL}"; do
        interface_setup="$(get_network_interface_details "${interface_name}")"
        interface_status="$(get_network_interface_status "${interface_name}")"

        if [[ "${interface_setup}" == "" ]]; then
            exception 1 "Interface ${interface} doesn't exist."
        fi

        if [[ "${interface_status}" != "active" ]]; then
            exception 1 "Interface ${interface_name} is not online."
        fi
    done
}

function get_network_interface_details()
{
    if [[ $# -ne 1 ]]; then
        exception 1 "Improper function call: ${FUNCNAME[0]} <interface-name>"
    fi

    interface_name="$1"

    ifconfig "${interface_name}" 2> /dev/null || echo ""
}

function get_network_interface_status()
{
    if [[ $# -ne 1 ]]; then
        exception 1 "Improper function call: ${FUNCNAME[0]} <interface-name>"
    fi

    interface_name="$1"

    get_network_interface_details "${interface_name}" | egrep '^\s+status:' | cut -d" " -f 2 || echo ""
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
