# https://hub.docker.com/_/node
# https://foundryvtt.com/article/installation/
# https://foundryvtt.com/article/configuration/
# https://foundryvtt.com/article/requirements/ # --> Node 18 Recommended & glibc 2.28+
# https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md

ARG NODE_IMAGE_VERSION

FROM node:${NODE_IMAGE_VERSION}

ENV \
  APP_USER="node" \
  APP_NAME="foundryvtt" \
  FOUNDRY_RELEASE_URL="" \
  DATA_PATH="/data" \  
  SCRIPTS="/usr/local/bin" \
  LOGS="/var/log" \
  TERM="xterm-256color"

ENV \
  APP_FILES="/home/$APP_USER/$APP_NAME"

RUN apk --update --no-cache add tzdata &&\
    mkdir -p $DATA_PATH $APP_FILES $SCRIPTS &&\
    chown -R $APP_USER:$APP_USER $DATA_PATH $APP_FILES $SCRIPTS &&\
    ln -s $APP_FILES /app

USER $APP_USER

COPY --chown=$APP_USER:$APP_USER scripts $SCRIPTS

EXPOSE 30000/TCP

VOLUME ["$DATA_PATH"]

ENTRYPOINT ["/bin/ash", "-c"]
CMD ["$SCRIPTS/fvtt_up.sh"]