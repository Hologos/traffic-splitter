function yaml_load()
{
    if [[ $# -ne 1 ]]; then
        exception 1 "No filepath to a config file given."
    fi

    local config_filepath="$1"

    if [[ ! -r "${config_filepath}" ]]; then
        exception 1 "Cannot open config file '${config_filepath}'."
    fi

    python -c '
import yaml, sys, os

def recursive_print(param, prefix):
    if type(param) is dict:
        for key in param:
            recursive_print(param[key], prefix + key +":")
    elif type(param) is list:
        for index, value in enumerate(param):
            recursive_print(value, prefix + str(index) +":")
    else:
        print prefix + str(param)

config_content = yaml.safe_load(sys.stdin)
recursive_print(config_content, "")
' < "${config_filepath}" 2> /dev/null || exception 1 "Cannot load yaml config due to an error."
}

function yaml_get_value()
{
    if [[ $# -ne 2 ]]; then
        exception 1 "Improper function call: ${FUNCNAME[0]} <yaml-string> <path-to-key>"
    fi

    local config_content="$1"
    local key_path="$2"

    for search_match in \
        "$(echo "${config_content}" | egrep -E '^'"${key_path}"':[^:]+$' 2> /dev/null || echo "")" \
        "$(echo "${config_content}" | egrep -E '^'"$key_path"':[0-9]+:[^:]+$' 2> /dev/null || echo "")"
    do
        if [[ "${search_match}" == "" ]]; then
            continue
        fi

        local depth="$(echo "${search_match}" | head -n 1 | tr ':' "\n" | wc -l)"

        echo "${search_match}" | cut -d: -f ${depth}

        # we found the match, stop futher proccessing
        break
    done
}
