#!/bin/sh
source $SCRIPTS/fvtt_logging_functions
source $SCRIPTS/fvtt_server_functions
LOG_NAME="fvtt_up.sh"

# Store the Foundry VTT process ID
FOUNDRY_PID=""

# Function to handle shutdown
cleanup() {
    log "Received shutdown signal. Starting graceful shutdown..."
    
    # Check if Foundry VTT process is running and send SIGTERM
    if [ -n "$FOUNDRY_PID" ]; then
        log "Sending SIGTERM to Foundry VTT process (PID: $FOUNDRY_PID)"
        
        # Send termination signal to the process
        kill -TERM "$FOUNDRY_PID"
        
        # Wait for the process to terminate
        wait "$FOUNDRY_PID"
        
        # Check if the process terminated successfully
        if [ $? -ne 0 ]; then
            log_error "Failed to stop Foundry VTT process with PID $FOUNDRY_PID."
        else
            log "Foundry VTT process stopped successfully."
        fi
    else
        log_warning "No Foundry VTT process PID found, skipping shutdown."
    fi
    
    # Final check for lock directory to handle unsafe shutdown
    check_lock
    log "Cleanup complete. Exiting..."
    
    # Exit gracefully
    exit 0
}

# Function to check and clean up the lock directory
check_lock() {
    LOCK_DIR="$DATA_PATH/Config/options.json.lock"
    if [ -d "$LOCK_DIR" ]; then
        log_error "Detected an unsafe shutdown. The lock directory '$LOCK_DIR' exists."
        # Uncomment the next line if you want to automatically remove the lock
        # rm -rf "$LOCK_DIR"
    fi
}

# Set up signal trap with signal logging
trap 'log "Received signal: $?" && cleanup' SIGTERM SIGINT SIGQUIT

# Initial lock check
check_lock

# Perform application update and environment option update
update_app
update_options_from_env

# log_tails
# FIXME tail won't pickup new logs until reboot
# tail -f $LOGS/debug*.log | jq --color-output -r 'select(.level == "info") | .timestamp + " - [" + .level + "] - " + .message'
# tail -f $LOGS/error*.log | jq --color-output -r 'select(.level == "info") | .timestamp + " - [" + .level + "] - " + .message'

# Start Foundry VTT in the background
node $APP_FILES/main.mjs \
    --port=30000 \
    --headless \
    --dataPath=$DATA_PATH \
    --noupnp \
    --noipdiscovery \
    --noupdate \
    --logsize=1024k \
    --maxlogs=1 &

# Store the PID
FOUNDRY_PID=$!
log "Started Foundry VTT process with PID: $FOUNDRY_PID"

# Wait for the Foundry VTT process
wait $FOUNDRY_PID