function verify_network_interfaces()
{
    if [[ "${INTERFACE_DEFAULT}" == "" ]]; then
        terminate "Default interface is not specified."
    fi

    if [[ "${INTERFACE_TUNNEL}" == "" ]]; then
        terminate "Tunnel interface is not specified."
    fi

    for interface_name in "${INTERFACE_DEFAULT}" "${INTERFACE_TUNNEL}"; do
        local interface_setup="$(get_network_interface_details "${interface_name}")"
        local interface_status="$(get_network_interface_status "${interface_name}")"

        if [[ "${interface_setup}" == "" ]]; then
            terminate "Interface ${interface_name} doesn't exist."
        fi

        if [[ "${interface_status}" != "active" ]] && [[ "${interface_name}" != utun* ]]; then
            terminate "Interface ${interface_name} is not online."
        fi
    done
}

function get_network_interface_details()
{
    if [[ $# -ne 1 ]]; then
        exception 1 "Improper function call: ${FUNCNAME[0]} <interface-name>"
    fi

    local interface_name="$1"

    ifconfig "${interface_name}" 2> /dev/null || echo ""
}

function get_network_interface_status()
{
    if [[ $# -ne 1 ]]; then
        exception 1 "Improper function call: ${FUNCNAME[0]} <interface-name>"
    fi

    local interface_name="$1"

    get_network_interface_details "${interface_name}" | egrep '^\s+status:' | cut -d" " -f 2 || echo ""
}

function restart_and_check_network_interfaces()
{
    restart_network_interfaces &
    sleep 1
    check_network_status
}

function restart_network_interfaces()
{
    for interface_status in "down" "up"; do
        for interface_name in "${INTERFACE_DEFAULT}" "${INTERFACE_TUNNEL}"; do
            set_network_interface_status "${interface_name}" "${interface_status}"
        done
    done
}

function set_network_interface_status()
{
    if [[ $# -ne 2 ]]; then
        exception 1 "Improper function call: ${FUNCNAME[0]} <interface-name> <interface-status>"
    fi

    local interface_name="$1"
    local interface_status="$2"

    if [[ "${interface_status}" != "up" ]] && [[ "${interface_status}" != "down" ]]; then
        terminate "Forbidden interface status '${interface_status}'."
    fi

    ifconfig "${interface_name}" "${interface_status}"
}

function check_network_status()
{
    echo
    echo "${FORMAT_BOLD}Restarting network interfaces${FORMAT_NORMAL}"

    local interface_statuses=()
    local counter=0

    while true; do
        local index=0

        for checked_network_interface in "${INTERFACE_DEFAULT}" "${INTERFACE_TUNNEL}"; do
            local interface_status="$(get_network_interface_status "${checked_network_interface}")"
            local interface_status_formatted="${FORMAT_FOREGROUND_RED}unknown${FORMAT_NORMAL}"

            if [[ "${interface_status}" == "" ]]; then
                terminate "There is a problem with interface ${checked_network_interface}."
            fi

            case "${interface_status}" in
                inactive)
                    interface_status_formatted="${FORMAT_FOREGROUND_RED}offline${FORMAT_NORMAL}"
                ;;

                active)
                    local interface_gateway="$(get_gateway_of_interface "${checked_network_interface}")"

                    if [[ "${interface_gateway}" == "" ]]; then
                        interface_status="not-connected"
                        interface_status_formatted="${FORMAT_FOREGROUND_BLUE}not connected${FORMAT_NORMAL}"
                    else
                        interface_status_formatted="${FORMAT_FOREGROUND_GREEN}online${FORMAT_NORMAL}"
                    fi
                ;;

                *)
                    terminate "Unknown interface status '${interface_status}' of interface ${checked_network_interface}."
            esac

            interface_statuses[${index}]="${interface_status}"

            echo -n "   "
            echo "Interface ${checked_network_interface} status: ${interface_status_formatted}"

            index=$(( ${index} + 1 ))
        done

        # end here
        if [[ "$(echo "${interface_statuses[@]}" | grep -v 'not-connected' | grep -v 'inactive' | grep -v 'grep')" != "" ]]; then
            break
        fi

        sleep 1

        counter=$(( ${counter} + 1 ))

        # safe break
        if [[ ${counter} -gt 30 ]]; then
            terminate "Waiting for network interfaces coming online timed out."
        fi

        echo -ne "${FORMAT_UP_ONE_LINE}"
        echo -ne "${FORMAT_CLEAR_TO_EOL}"
        echo -ne "${FORMAT_UP_ONE_LINE}"
        echo -ne "${FORMAT_CLEAR_TO_EOL}"
    done
}
