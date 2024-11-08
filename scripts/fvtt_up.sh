#!/bin/sh
source $SCRIPTS/fvtt_logging_functions
source $SCRIPTS/fvtt_server_functions

update_app
# permissions
update_options_from_env

log "Running on Alpine - Version $(cat /etc/alpine-release)"

node $APP_FILES/main.mjs \
    --port=30000 \
    --headless \
    --dataPath=$DATA_PATH \
    --noupnp \
    --noupdate