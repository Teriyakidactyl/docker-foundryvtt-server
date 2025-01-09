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

# Function to build Foundry command line flags
build_foundry_flags() {
    # Initialize FOUNDRY_FLAGS as an empty string
    FOUNDRY_FLAGS=""

    # Base flags that are always included
    FOUNDRY_FLAGS="--headless --dataPath=$DATA_PATH --noupnp --noipdiscovery --noupdate --logsize=1024k --maxlogs=1"
    
    # Add port if specified, otherwise use default
    FOUNDRY_FLAGS="$FOUNDRY_FLAGS --port=${FOUNDRY_PORT:-30000}"
    
    # Optional flags based on environment variables
    [ -n "$FOUNDRY_ADMIN_PASSWORD" ] && FOUNDRY_FLAGS="$FOUNDRY_FLAGS --adminPassword=$FOUNDRY_ADMIN_PASSWORD"
    [ -n "$FOUNDRY_SSL_CERT" ] && FOUNDRY_FLAGS="$FOUNDRY_FLAGS --sslCert=$FOUNDRY_SSL_CERT"
    [ -n "$FOUNDRY_SSL_KEY" ] && FOUNDRY_FLAGS="$FOUNDRY_FLAGS --sslKey=$FOUNDRY_SSL_KEY"
    [ -n "$FOUNDRY_WORLD" ] && FOUNDRY_FLAGS="$FOUNDRY_FLAGS --world=$FOUNDRY_WORLD"
    [ -n "$FOUNDRY_PROXY_PORT" ] && FOUNDRY_FLAGS="$FOUNDRY_FLAGS --proxyPort=$FOUNDRY_PROXY_PORT"
    [ -n "$FOUNDRY_PROXY_SSL" ] && FOUNDRY_FLAGS="$FOUNDRY_FLAGS --proxySSL=$FOUNDRY_PROXY_SSL"
    [ -n "$FOUNDRY_ROUTE_PREFIX" ] && FOUNDRY_FLAGS="$FOUNDRY_FLAGS --routePrefix=$FOUNDRY_ROUTE_PREFIX"
    [ -n "$FOUNDRY_PASSWORD_SALT" ] && FOUNDRY_FLAGS="$FOUNDRY_FLAGS --passwordSalt=$FOUNDRY_PASSWORD_SALT"
    [ -n "$FOUNDRY_UPNP_LEASE_DURATION" ] && FOUNDRY_FLAGS="$FOUNDRY_FLAGS --upnpLeaseDuration=$FOUNDRY_UPNP_LEASE_DURATION"
    
    # Boolean flags
    [ "${FOUNDRY_COMPRESS_STATIC:-true}" = "true" ] && FOUNDRY_FLAGS="$FOUNDRY_FLAGS --compressStatic"
    [ "${FOUNDRY_COMPRESS_SOCKET:-true}" = "true" ] && FOUNDRY_FLAGS="$FOUNDRY_FLAGS --compressSocket"
    [ "${FOUNDRY_FULL_SCREEN:-false}" = "true" ] && FOUNDRY_FLAGS="$FOUNDRY_FLAGS --fullscreen"
    [ "${FOUNDRY_NO_BACKUPS:-false}" = "true" ] && FOUNDRY_FLAGS="$FOUNDRY_FLAGS --noBackups"
    
    # Log each flag separately
    log "Starting Foundry VTT with flags:"
    for flag in $FOUNDRY_FLAGS; do
        if echo "$flag" | grep -iq "password"; then
            # Don't output passwords into logs
            flag=$(echo "$flag" | sed 's/=\(.*\)/=\******/')
        fi
        log "$flag"
    done
}

# Set up signal trap with signal logging
trap 'log "Received signal: $?" && cleanup' SIGTERM SIGINT SIGQUIT

# Initial lock check
check_lock

# Perform application update and environment option update
update_app
update_options_from_env

# Build command line flags
build_foundry_flags

# Start Foundry VTT in the background
node $APP_FILES/main.mjs $FOUNDRY_FLAGS &

# Store the PID
FOUNDRY_PID=$!
log "Started Foundry VTT process with PID: $FOUNDRY_PID"

# Wait for the Foundry VTT process
wait $FOUNDRY_PID