#!/bin/sh
source $SCRIPTS/fvtt_logging_functions
source $SCRIPTS/fvtt_server_functions

LOG_NAME="fvtt_up.sh"
log "Running on Alpine - Version $(cat /etc/alpine-release)"

# Function to check and clean up the lock directory
check_lock() {
    LOCK_DIR="$DATA_PATH/Config/options.json.lock"
    if [ -d "$LOCK_DIR" ]; then
        log_error "Detected an unsafe shutdown. The lock directory '$LOCK_DIR' exists."
        # Optionally remove the lock directory to clean up (comment out if not needed)
        # rm -rf "$LOCK_DIR"
    fi
}

# Initial lock check
check_lock

# Perform application update and environment option update
update_app
update_options_from_env

# log_tails
# FIXME tail won't pickup new logs until reboot
# tail -f $LOGS/debug*.log | jq --color-output -r 'select(.level == "info") | .timestamp + " - [" + .level + "] - " + .message'
# tail -f $LOGS/error*.log | jq --color-output -r 'select(.level == "info") | .timestamp + " - [" + .level + "] - " + .message'

# https://foundryvtt.com/article/configuration/ > Command Line Flag Listing
node $APP_FILES/main.mjs \
    --port=30000 \
    --headless \
    --dataPath=$DATA_PATH \
    --noupnp \
    --noipdiscovery \
    --noupdate \
    --logsize=1024k \
    --maxlogs=1

    # > $LOGS/main_mjs.$(date +"%Y-%m-%d").log 2>&1
    # NOTE $LOGS/debug.*.log already contains output

# Check lock directory again after FoundryVTT process finishes
check_lock

# Final log entry after the process exits
log "FoundryVTT process has exited. Container will now stop."