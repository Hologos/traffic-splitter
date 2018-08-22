function alter_routing_table()
{
    echo
    echo "${FORMAT_BOLD}Transforming routing table${FORMAT_NORMAL}"

    # determines gateways of specified interfaces
    determine_gateways_of_interfaces

    # deletes default routes of specified interfaces
    delete_default_routes_of_interfaces

    # adds default route for default interface
    add_default_route_for_default_interface

    # adds routes for tunnel interface
    add_routes_for_tunnel_interface

    # verifies routes
    verify_routes
}

function determine_gateways_of_interfaces()
{
    # TODO: determine IP addresses from ifconfig instead of netstat
    GATEWAY_INTERFACE_DEFAULT="$(netstat -nrf inet | egrep '^default\s+([^\s]+)(\s+[^\s]+){3}\s+' | egrep "${INTERFACE_DEFAULT}$" | awk '{print $2}' || echo "")"
    GATEWAY_INTERFACE_TUNNEL="$(netstat -nrf inet | egrep '^default\s+([^\s]+)(\s+[^\s]+){3}\s+' | egrep "${INTERFACE_TUNNEL}$" | awk '{print $2}' || echo "")"

    if [[ "${GATEWAY_INTERFACE_DEFAULT}" == "" ]]; then
        exception 1 "No default gateway for default interface found."
    fi

    if [[ "${GATEWAY_INTERFACE_TUNNEL}" == "" ]]; then
        exception 1 "No tunnel gateway for default interface found."
    fi

    echo -n "   "
    echo "${FORMAT_UNDERLINE}Discovered gateways${FORMAT_NORMAL}"

    echo -n "   "
    echo "Default (interface ${INTERFACE_DEFAULT}): ${GATEWAY_INTERFACE_DEFAULT}"

    echo -n "   "
    echo "Tunnel (interface ${INTERFACE_TUNNEL}): ${GATEWAY_INTERFACE_TUNNEL}"
}

function delete_default_routes_of_interfaces()
{
    route -n delete default -ifscope "${INTERFACE_DEFAULT}" > /dev/null
    route -n delete -net default -interface "${INTERFACE_TUNNEL}" > /dev/null
}

function add_default_route_for_default_interface()
{
    route -n add -net default "${GATEWAY_INTERFACE_DEFAULT}" > /dev/null
}

function add_routes_for_tunnel_interface()
{
    echo
    echo -n "   "
    echo "${FORMAT_UNDERLINE}Tunnel routes (interface: ${INTERFACE_TUNNEL})${FORMAT_NORMAL}"

    for subnet in ${SUBNETS_TUNNEL}; do
        echo -n "   "
        echo "${subnet}"

        route -n add -net "${subnet}" "${GATEWAY_INTERFACE_TUNNEL}" > /dev/null #2>&1 # TODO: consider uncomment or removal
    done
}

function verify_routes()
{
    echo
    echo "${FORMAT_BOLD}Verifying routes${FORMAT_NORMAL}"

    echo -n "   "
    echo "${FORMAT_UNDERLINE}Tunnel (interface: ${INTERFACE_TUNNEL})${FORMAT_NORMAL}"

    for hostname_to_test in ${TEST_HOSTNAMES_TUNNEL}; do
        verify_route "${hostname_to_test}"
    done

    echo
    echo -n "   "
    echo "${FORMAT_UNDERLINE}Default (interface: ${INTERFACE_DEFAULT})${FORMAT_NORMAL}"

    for hostname_to_test in ${TEST_HOSTNAMES_DEFAULT}; do
        verify_route "${hostname_to_test}"
    done
}

function verify_route()
{
    if [[ $# -ne 1 ]]; then
        exception 1 "Improper function call: ${FUNCNAME[0]} <hostname-to-test>"
    fi

    hostname_to_test="$1"

    test_result="$(route get "${hostname_to_test}" 2> /dev/null | egrep 'interface:\s+([^\s]+)' | awk '{ print $2 }' || echo "")"

    echo -n "   "

    if [[ "${test_result}" != "" ]]; then
        echo "${hostname_to_test} ... ${FORMAT_FOREGROUND_GREEN}ok${FORMAT_NORMAL}"
    else
        echo "${hostname_to_test} ... ${FORMAT_FOREGROUND_RED}error${FORMAT_NORMAL}"
    fi
}
