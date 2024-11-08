#!/bin/sh
source $SCRIPTS/fvtt_logging_functions
source $SCRIPTS/fvtt_server_functions

update_app
# permissions
update_options_from_env

log "Running on Alpine - Version $(cat /etc/alpine-release)"

log_tails

# https://foundryvtt.com/article/configuration/ > Command Line Flag Listing
node $APP_FILES/main.mjs \
    --port=30000 \
    --headless \
    --dataPath=$DATA_PATH \
    --noupnp \
    --noipdiscovery \
    --noupdate \
    --logsize=1024k \
    --maxlogs=3 > $LOGS/main_mjs.log 2>&1

# TODO tail $DATA_PATH/Logs/*