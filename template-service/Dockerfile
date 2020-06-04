ARG NODE_VERSION=10.16.3
FROM node:${NODE_VERSION}-alpine

# Bash + misc utilities
RUN apk add --no-cache bash curl jq

WORKDIR /home/node
USER node

COPY start-template-service.sh ./

ENTRYPOINT ["/bin/bash", "start-template-service.sh"]
