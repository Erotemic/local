#!/bin/bash
__doc__="
Helper script to start docker compose and print a URL to navigate to.

Ignore:
    See Also: ~/local/homelinks/helpers/alias_helpers.sh in ollama-web

    cd ~/local/services/ollama-web
    ~/local/services/ollama-web/start.sh
"
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	# Running as a script
	set -eo pipefail
fi


start_main(){
    SERVICE_DPATH="$(dirname "${BASH_SOURCE[0]}")"
    echo "Service directory:"
    echo "SERVICE_DPATH=$SERVICE_DPATH"

    ARGS=("$@")

    echo "ARGS: " "${ARGS[@]}"
    if [ ${#ARGS[@]} -eq 0 ]; then
        # If no args are given, then use up -d as the default.
        ARGS=(up -d)
    fi
    echo "ARGS: " "${ARGS[@]}"

    docker-compose --file "$SERVICE_DPATH"/docker-compose.yml "${ARGS[@]}"

    # Show address
    if [[ "${ARGS[0]}" == "up" ]]; then
        export OPENWEBUI_PORT=14771
        ip_addresses=(0.0.0.0)
        while IFS= read -r line; do
            ip_addresses+=("$line")
        done < <(ip -4 -o addr show scope global | grep -vE 'docker|virbr0' | awk '{print $4}' | cut -d'/' -f1)
        echo "${ip_addresses[@]}"
        echo "Server is available on IP Addresses:"
        for ip_address in "${ip_addresses[@]}"
        do
            echo "    http://${ip_address}:${OPENWEBUI_PORT}"
        done
    fi
}

run_command(){
    SERVICE_DPATH="$(dirname "${BASH_SOURCE[0]}")"
    echo "Service directory: $SERVICE_DPATH"
    docker-compose --file "$SERVICE_DPATH"/docker-compose.yml "${@}"
}


if [[ ${BASH_SOURCE[0]} != "$0" ]]; then
    # We are sourcing the library
    echo "Sourcing prepare_system as a library and environment"
else
    start_main "${@}"
    exit $?
fi
