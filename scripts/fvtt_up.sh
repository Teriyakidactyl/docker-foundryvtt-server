#!/bin/sh
source $SCRIPTS/fvtt_logging_functions
source $SCRIPTS/fvtt_server_functions

update_app
# permissions
update_options_from_env

LOG_NAME="fvtt_up.sh"
log "Running on Alpine - Version $(cat /etc/alpine-release)"

# Check for unsafe shutdown via 'options.json.lock'
LOCK_FILE="$DATA_PATH/Config/options.json.lock"
if [ -f "$LOCK_FILE" ]; then
    log_error "Detected an unsafe shutdown. The lock file '$LOCK_FILE' exists."
    # Optionally remove the lock file to clean up (comment out if not needed)
    # rm -f "$LOCK_FILE"
fi

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
