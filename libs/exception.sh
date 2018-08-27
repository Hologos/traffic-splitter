function exception()
{
    if [[ $# -ne 2 ]]; then
        >&2 echo "Usage: exception <rc> <message>"
        exit 1
    fi

    local rc="$1"
    local message="$2"

    >&2 echo
    >&2 echo "Exception [code: ${rc}]: ${message}"

    exit "${rc}"
}
