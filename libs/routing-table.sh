function alter_routing_table()
{
    echo
    echo "${FORMAT_BOLD}Transforming routing table${FORMAT_NORMAL}"

    # get gateways of specified interfaces
    get_gateways_of_interfaces

    # deletes default routes of specified interfaces
    delete_default_routes_of_interfaces

    # adds default route for default interface
    add_default_route_for_default_interface

    # adds routes for tunnel interface
    add_routes_for_tunnel_interface

    # verifies routes
    verify_routes
}

function get_gateways_of_interfaces()
{
    GATEWAY_INTERFACE_DEFAULT="$(get_gateway_of_interface "${INTERFACE_DEFAULT}")"
    GATEWAY_INTERFACE_TUNNEL="$(get_gateway_of_interface "${INTERFACE_TUNNEL}")"

    if [[ "${GATEWAY_INTERFACE_DEFAULT}" == "" ]]; then
        terminate "No default gateway for default interface found."
    fi

    if [[ "${GATEWAY_INTERFACE_TUNNEL}" == "" ]]; then
        terminate "No default gateway for tunnel interface found."
    fi

    echo -n "   "
    echo "${FORMAT_UNDERLINE}Discovered gateways${FORMAT_NORMAL}"

    echo -n "   "
    echo "Default (interface ${INTERFACE_DEFAULT}): ${GATEWAY_INTERFACE_DEFAULT}"

    echo -n "   "
    echo "Tunnel (interface ${INTERFACE_TUNNEL}): ${GATEWAY_INTERFACE_TUNNEL}"
}

function get_gateway_of_interface()
{
    if [[ $# -ne 1 ]]; then
        exception 1 "Improper function call: ${FUNCNAME[0]} <interface-name>"
    fi

    local interface_name="$1"

    netstat -nrf inet | egrep '^default\s+([^\s]+)(\s+[^\s]+){3}\s+' | egrep "${interface_name}$" | awk '{ print $2 }' || echo ""
}

function delete_default_routes_of_interfaces()
{
    # TODO: if error message, mark it somehow in the output
    route -n delete default -ifscope "${INTERFACE_DEFAULT}" > /dev/null
    route -n delete -net default -interface "${INTERFACE_TUNNEL}" > /dev/null
}

function add_default_route_for_default_interface()
{
    # TODO: if error message, mark it somehow in the output
    route -n add -net default "${GATEWAY_INTERFACE_DEFAULT}" > /dev/null
}

function add_routes_for_tunnel_interface()
{
    echo
    echo -n "   "
    echo "${FORMAT_UNDERLINE}Tunnel routes (interface: ${INTERFACE_TUNNEL})${FORMAT_NORMAL}"

    for subnet in ${SUBNETS_TUNNEL}; do
        echo -n "   "
        echo -n "${subnet}"

        local route_cmd_output=""

        # FIX: route -n add -net <subnet> <gateway-ip> works only if the gateway is IP,
        #      route -n add -interface <interface-name> for utun* interfaces.
        if [[ "${INTERFACE_TUNNEL}" != utun* ]]; then
            route_cmd_output="$(route -n add -net "${subnet}" "${GATEWAY_INTERFACE_TUNNEL}" 2>&1)"
        else
            route_cmd_output="$(route -n add -net "${subnet}" -interface "${INTERFACE_TUNNEL}" 2>&1)"
        fi

        if [[ "$(echo "${route_cmd_output}" | egrep -E "^add net \d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}: gateway $GATEWAY_INTERFACE_TUNNEL\$")" != "" ]]; then
            echo " ${FORMAT_FOREGROUND_YELLOW}(already exists)${FORMAT_NORMAL}"
        else
            echo
        fi
    done
}

function verify_routes()
{
    echo
    echo "${FORMAT_BOLD}Verifying routes${FORMAT_NORMAL}"

    echo -n "   "
    echo "${FORMAT_UNDERLINE}Tunnel (interface: ${INTERFACE_TUNNEL})${FORMAT_NORMAL}"

    for hostname_to_test in ${TEST_HOSTNAMES_TUNNEL}; do
        verify_route "${hostname_to_test}" "${INTERFACE_TUNNEL}"
    done

    echo
    echo -n "   "
    echo "${FORMAT_UNDERLINE}Default (interface: ${INTERFACE_DEFAULT})${FORMAT_NORMAL}"

    for hostname_to_test in ${TEST_HOSTNAMES_DEFAULT}; do
        verify_route "${hostname_to_test}" "${INTERFACE_DEFAULT}"
    done
}

function verify_route()
{
    if [[ $# -ne 2 ]]; then
        exception 1 "Improper function call: ${FUNCNAME[0]} <hostname-to-test> <interface-name>"
    fi

    local hostname_to_test="$1"
    local interface_name="$2"

    local real_interface_name="$(route get "${hostname_to_test}" 2> /dev/null | egrep 'interface:\s+([^\s]+)' | awk '{ print $2 }' || echo "")"

    echo -n "   "

    if [[ "${real_interface_name}" != "${interface_name}" ]]; then
        echo "${hostname_to_test} ... ${FORMAT_FOREGROUND_RED}wrong interface (${real_interface_name})${FORMAT_NORMAL}"
    elif [[ "${real_interface_name}" != "" ]]; then
        echo "${hostname_to_test} ... ${FORMAT_FOREGROUND_GREEN}ok${FORMAT_NORMAL}"
    else
        echo "${hostname_to_test} ... ${FORMAT_FOREGROUND_RED}error${FORMAT_NORMAL}"
    fi
}
