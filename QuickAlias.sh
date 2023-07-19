set -u
declare -A aliases_array
overwrite_protection=1

function add_element {
    local key value add_call_type
    key="${1%=*}"
    value="${1#*=}"
    add_call_type="$2"

    if [ "$overwrite_protection" -eq 1 ] && ( type "$key" 1>/dev/null 2>&1 ) ; then
        echo "Warning: Tried to add alias to '$key', but it's already defined and overwrite protection is on"
        return 1
    fi

    aliases_array["$key"]="$value"
    if [[ "$add_call_type" != "DRY" ]] ; then echo "$1" >> /etc/aliases_array_file.txt ; fi
}

function remove_element {
    local key remove_call_type
    key="$1"
    remove_call_type="$2"

    if [ "${aliases_array[$key]+exists}" ]; then : ; else
        echo "Warning: The key '$key' does not exists"
        return 1
    fi

    unset "aliases_array[$key]"
    
    if [[ "$remove_call_type" != "DRY" ]] ; then
        # Necessary due to potential permissions issues
        cp /etc/aliases_array_file.txt /tmp/cp_aaf_into_tmp.txt
        sed -i "/^$key=/d" /tmp/cp_aaf_into_tmp.txt
        cp /tmp/cp_aaf_into_tmp.txt /etc/aliases_array_file.txt
    fi
}

function make_aliases {
    local key
    for key in "${!aliases_array[@]}"; do
        if [ "$overwrite_protection" -eq 1 ] && ( type "$key" 1>/dev/null 2>&1 ) ; then
            echo "Warning: Tried to use alias '$key', but it's already defined and overwrite protection is on"
        else
            alias "$key"="${aliases_array[$key]}"
        fi
    done
}

function unmake_aliases {
    local key unmake_call_type
    unmake_call_type="$1"

    for key in "${!aliases_array[@]}"; do
        unalias "$key"
        if [[ "$unmake_call_type" == "EMPTY_ARRAY" ]] ; then remove_element "$key" "DRY" ; fi
    done
}

function load_array {
    local line

    if [ -f /etc/aliases_array_file.txt ]; then
        while IFS= read -r line; do
            add_element "$line" "DRY"
        done < /etc/aliases_array_file.txt
    fi
}

function reset_array {
    unmake_aliases "EMPTY_ARRAY"
    load_array
    make_aliases
}

function remove_alias {
    if ( remove_element "$1" "SAVE" ) ; then
        unalias "$1"
    fi
    reset_array
}

function add_alias {
    add_element "$1" "SAVE"
    alias "$1"
    reset_array
}

function path_alias {
    local key value
    key="$1"
    value="$PWD"
    add_alias "$key"'=cd '"$value"
}

function print_aliases {
    local key
    for key in "${!aliases_array[@]}"; do echo "* $key -> ${aliases_array[$key]}" ; done
}

function start_smart_aliases {

    # Lock is useful in case anything is improperly defined and code is added to ".bash_aliases"
    if [ -f "/tmp/lock_disable_aliases_for_now" ]; then
        echo "Warning: File /tmp/lock_disable_aliases_for_now already exists. Skipping aliases."
        return 1
    fi

    echo "Debug: Setting up aliases"
    touch "/tmp/lock_disable_aliases_for_now"
    load_array
    make_aliases
    function echos_for_aliases_in_alias_management {
        echo "> ah: help with aliases (this)"
        echo "> ad: add alias [ format: <key>=<value>, example aone=a0 ]"
        echo "> ap: add current path as alias"
        echo "> ar: remove alias"
        echo "> al: list aliases"
    }
    alias ah=echos_for_aliases_in_alias_management
    alias ad=add_alias
    alias ap=path_alias
    alias ar=remove_alias
    alias al=print_aliases
    rm "/tmp/lock_disable_aliases_for_now"

}

start_smart_aliases
