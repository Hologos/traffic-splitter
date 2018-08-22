function usage()
{
    >&2 echo
    >&2 echo "Usage: $0 [-r|-v] -c <config-filepath> -d <interface-name> -t <interface-name>"
    >&2 echo ""
    >&2 echo "${FORMAT_BOLD}OPTIONS${FORMAT_NORMAL}"
    >&2 echo "    -c, --config"
    >&2 echo "        Specifies filepath to a config file (YAML format)."
    >&2 echo ""
    >&2 echo "    -d, --default-interface"
    >&2 echo "        Specifies default interface where the rest of traffic is routed to."
    >&2 echo ""
    >&2 echo "    -t, --tunnel-interface"
    >&2 echo "        Specifies tunnel interface where specified traffic is routed to."
    >&2 echo ""
    >&2 echo "    -r, --restart-interfaces"
    >&2 echo "        Restarts specified interfaces."
    >&2 echo ""
    >&2 echo "    -v --verify"
    >&2 echo "        Only verifies routes (doesn't alter routing table)."
}
