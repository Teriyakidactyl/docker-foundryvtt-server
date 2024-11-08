# https://hub.docker.com/_/node
# https://foundryvtt.com/article/installation/
# https://foundryvtt.com/article/configuration/
# https://foundryvtt.com/article/requirements/ # --> Node 18 Recommended & glibc 2.28+
# https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md

# Resource compare: 11/8/2024
# NAME             CPU %     MEM USAGE / LIMIT     MEM %     NET I/O          BLOCK I/O        PIDS
# FoundryVTT_Feld  0.00%     157MiB / 955.1MiB     16.44%    236MB / 1.27MB   215MB / 504MB    12
# FoundryVTT_This  0.00%     63.86MiB / 955.1MiB   6.69%     138kB / 2.56MB   1.35MB / 348kB   12

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

RUN apk --update --no-cache add tzdata jq &&\
    mkdir -p $DATA_PATH $APP_FILES $SCRIPTS &&\
    chown -R $APP_USER:$APP_USER $DATA_PATH $APP_FILES $SCRIPTS &&\
    ln -s $APP_FILES /app

USER $APP_USER

COPY --chown=$APP_USER:$APP_USER scripts $SCRIPTS

EXPOSE 30000/TCP

VOLUME ["$DATA_PATH"]

ENTRYPOINT ["/bin/ash", "-c"]
CMD ["$SCRIPTS/fvtt_up.sh"]