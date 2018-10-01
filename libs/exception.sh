function print_stack()
{
    local stack_size="${#FUNCNAME[@]}"

    >&2 echo
    >&2 echo "Stack trace:"

    # to skip print_stack() + exception(), start with index 2
    for (( i=2; i < ${stack_size}; i++ )); do
        local function_name="${FUNCNAME[$i]:-"MAIN"}"
        local source_line_number="${BASH_LINENO[$(( i - 1 ))]}"
        local function_source="${BASH_SOURCE[$i]:-"non_file_source"}"

        >&2 echo -n "   "
        >&2 echo "${function_source}:${source_line_number} -> ${function_name}()"
    done
}

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

    print_stack

    exit "${rc}"
}
