#!/bin/sh
source $SCRIPTS/fvtt_logging_functions
source $SCRIPTS/fvtt_server_functions

update_app

# permissions

log "Running on Alpine v$(cat /etc/alpine-release)"

node $APP_FILES/main.mjs \
    --port=30000 \
    --headless \
    --dataPath=$DATA_PATH \
    --noupnp \
    --noupdate