# https://hub.docker.com/_/node
# https://foundryvtt.com/article/installation/
# https://foundryvtt.com/article/configuration/
# https://foundryvtt.com/article/requirements/ # --> Node 18 Recommended & glibc 2.28+
# https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md

ARG FOUNDRY_VERSION
ARG NODE_IMAGE_VERSION="current-alpine"

FROM node:${NODE_IMAGE_VERSION}

ENV \
  APP_USER="node" \
  APP_NAME="foundryvtt" \
  APP_ARCHIVE="FoundryVTT-$FOUNDRY_VERSION.zip" \
  FOUNDRY_RELEASE_URL="" \
  DATA_PATH="/data" \  
  SCRIPTS="/usr/local/bin" \
  LOGS="/var/log" \
  TERM="xterm-256color"

ENV \
  APP_FILES="/home/$APP_USER/$APP_NAME"

RUN apk --update --no-cache add tzdata &&\
    mkdir -p $DATA_PATH $APP_FILES

USER $APP_USER

RUN mkdir -p $APP_FILES

COPY --chown=$APP_USER:$APP_USER scripts $SCRIPTS

EXPOSE 30000/TCP

VOLUME ["$DATA_PATH"]

ENTRYPOINT ["$SCRIPTS/fvtt_up.sh"] 

CMD ["node", "$APP_FILES/main.mjs", "--port=30000", "--headless", "--dataPath=$DATA_PATH", "--noupnp", "--noupdate"]
