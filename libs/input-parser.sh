ALTER=1
RESTART=0
VERIFY=0

function parse_input()
{
    if [[ $# -ne 6 ]] && [[ $# -ne 7 ]]; then
        usage
        exit 1
    fi

    while [[ $# -ne 0 ]] && [[ "$1" != "" ]]; do
        case $1 in
            -c | --config)
                shift

                if [[ $# -lt 1 ]]; then
                    exception 1 "Missing config filepath."
                fi

                CONFIG_FILEPATH="$1"
            ;;

            -d | --default-interface)
                shift

                if [[ $# -lt 1 ]]; then
                    exception 1 "Missing default interface name."
                fi

                INTERFACE_DEFAULT="$1"
            ;;

            -t | --tunnel-interface)
                shift

                if [[ $# -lt 1 ]]; then
                    exception 1 "Missing tunnel interface name."
                fi

                INTERFACE_TUNNEL="$1"
            ;;

            -r | --restart-interfaces)
                RESTART=1
            ;;

            -v | --verify)
                VERIFY=1
                ALTER=0
            ;;

            -h | --help)
                usage
                exit 1
            ;;

            *)
                exception 1 "Unknown input parameter '$1'."
        esac

        shift
    done
}
