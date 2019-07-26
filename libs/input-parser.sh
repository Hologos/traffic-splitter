ALTER=1
RESTART=0
VERIFY=0
NEEDS_SUDO=1

function parse_input()
{
    if [[ $# -eq 0 ]]; then
        usage
        exit 1
    fi

    CONFIG_FILEPATH_SET=0
    INTERFACE_DEFAULT_SET=0
    INTERFACE_TUNNEL_SET=0

    while [[ $# -ne 0 ]] && [[ "$1" != "" ]]; do
        case $1 in
            -c | --config)
                shift

                if [[ $# -lt 1 ]]; then
                    terminate "Missing config filepath."
                fi

                CONFIG_FILEPATH="$1"
                CONFIG_FILEPATH_SET=1
            ;;

            -d | --default-interface)
                shift

                if [[ $# -lt 1 ]]; then
                    terminate "Missing default interface name."
                fi

                INTERFACE_DEFAULT="$1"
                INTERFACE_DEFAULT_SET=1
            ;;

            -t | --tunnel-interface)
                shift

                if [[ $# -lt 1 ]]; then
                    terminate "Missing tunnel interface name."
                fi

                INTERFACE_TUNNEL="$1"
                INTERFACE_TUNNEL_SET=1
            ;;

            -r | --restart-interfaces)
                RESTART=1
            ;;

            -v | --verify)
                VERIFY=1
                ALTER=0
                NEEDS_SUDO=0
            ;;

            -h | --help)
                usage
                exit 1
            ;;

            *)
                terminate "Unknown input parameter '$1'."
        esac

        shift
    done

    if [[ ${CONFIG_FILEPATH_SET} -eq 0 ]]; then
        terminate "Configuration filepath was not set."
    elif [[ ${INTERFACE_DEFAULT_SET} -eq 0 ]]; then
        terminate "Default interface name was not set."
    elif [[ ${INTERFACE_TUNNEL_SET} -eq 0 ]]; then
        terminate "Tunnel interface name was not set."
    fi
}
