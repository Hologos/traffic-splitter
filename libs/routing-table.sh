function alter_routing_table()
{
    echo "Transforming routing table."

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
        exception 1 "No default gateway for default interface found."
    fi

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
    for subnet in 10.89 172.24.0.0/13; do
        route -n add -net "${subnet}" "${GATEWAY_INTERFACE_TUNNEL}" > /dev/null #2>&1 # TODO: consider uncomment or removal
    done
}

function verify_routes()
{
    echo "Verifying routes:"

    for test_hostname in "google.com" "seznam.cz" "prod-system.local" "dev-system.local" "non.existant.hostname"; do
        test_result="$(route get "${test_hostname}" 2> /dev/null | egrep 'interface:\s+([^\s]+)' | awk '{ print $2 }' || echo "")"

        echo -n "   "

        if [[ "${test_result}" != "" ]]; then
            echo "${test_hostname} ... ${FORMAT_FOREGROUND_GREEN}ok${FORMAT_NORMAL}"
        else
            echo "${test_hostname} ... ${FORMAT_FOREGROUND_RED}error${FORMAT_NORMAL}"
        fi
    done
}
