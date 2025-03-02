#!/bin/bash

# Standard script setup - DO NOT MODIFY
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"


# Source core imports
source "${DOCKER_SCRIPTS_DIR}/lib/core/imports.sh"

# Guard gegen mehrfaches Laden
if [ -n "${_CROWDSEC_ENV_LOADED+x}" ]; then
    return 0
fi
_CROWDSEC_ENV_LOADED=1

# Script configuration
SERVICE_NAME="traefik-crowdsec"
ENV_FILE="crowdsec.env"

print_header "Updating Crowdsec Environment"

# Get service directory
BASE_DIR=$(get_docker_dir "$SERVICE_NAME")
if [ $? -ne 0 ]; then
    print_status "Failed to get $SERVICE_NAME directory" "error"
    exit 1
fi

# Get user info
print_status "Getting user information..." "info"
get_user_info

# Define collections
COLLECTIONS="crowdsecurity/traefik crowdsecurity/http-cve crowdsecurity/whitelist-good-actors crowdsecurity/postfix crowdsecurity/dovecot crowdsecurity/nginx"

# Define environment variables
new_values=(
    "PUID:$USER_UID"
    "PGID:$USER_GID"
    "COLLECTIONS:$COLLECTIONS"
)

# Update environment file
if update_env_file "$BASE_DIR" "$ENV_FILE" "${new_values[@]}"; then
    print_status "Crowdsec environment file has been updated" "success"
else
    print_status "Failed to update environment file" "error"
    exit 1
fi