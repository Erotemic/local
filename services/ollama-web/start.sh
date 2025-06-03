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

    docker compose --file "$SERVICE_DPATH"/docker-compose.yml "${ARGS[@]}"

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

        # Wait for the container to start
        CONTAINER_NAME=open-webui
        TIMEOUT=300  # 5 minutes timeout in seconds
        START_TIME=$(date +%s)
        ELAPSED_TIME=0

        echo "Waiting for container '$CONTAINER_NAME' to be fully started (including health checks)..."

        while [ $ELAPSED_TIME -lt $TIMEOUT ]; do
            # Get container status and health status
            STATUS=$(docker inspect -f '{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null)
            HEALTH=$(docker inspect -f '{{.State.Health.Status}}' "$CONTAINER_NAME" 2>/dev/null)

            if [ $? -ne 0 ]; then
                echo "Error: Container '$CONTAINER_NAME' does not exist."
                return 1
            fi
            case $STATUS in
                "running")
                    if [ -z "$HEALTH" ]; then
                        # Container has no health check configured
                        echo "Container '$CONTAINER_NAME' is running (no health check configured)."
                        return 0
                    elif [ "$HEALTH" = "healthy" ]; then
                        echo "Container '$CONTAINER_NAME' is running and healthy."
                        return 0
                    elif [ "$HEALTH" = "unhealthy" ]; then
                        echo "Error: Container '$CONTAINER_NAME' is running but unhealthy."
                        return 1
                    else
                        echo "Container '$CONTAINER_NAME' is running but health status: $HEALTH"
                    fi
                    ;;
                "exited" | "dead")
                    # Get the exit code and error message if available
                    EXIT_CODE=$(docker inspect -f '{{.State.ExitCode}}' "$CONTAINER_NAME")
                    ERROR_MSG=$(docker inspect -f '{{.State.Error}}' "$CONTAINER_NAME")

                    echo "Error: Container '$CONTAINER_NAME' has failed with exit code $EXIT_CODE."
                    if [ -n "$ERROR_MSG" ]; then
                        echo "Error message: $ERROR_MSG"
                    fi
                    return 1
                    ;;
                *)
                    echo "Container '$CONTAINER_NAME' is in '$STATUS' state. Waiting..."
                    ;;
            esac
            sleep 1
            CURRENT_TIME=$(date +%s)
            ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
        done

    fi

}

run_command(){
    SERVICE_DPATH="$(dirname "${BASH_SOURCE[0]}")"
    echo "Service directory: $SERVICE_DPATH"
    docker compose --file "$SERVICE_DPATH"/docker-compose.yml "${@}"
}


if [[ ${BASH_SOURCE[0]} != "$0" ]]; then
    # We are sourcing the library
    echo "Sourcing prepare_system as a library and environment"
else
    start_main "${@}"
    exit $?
fi
