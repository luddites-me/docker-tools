ARG NODE_VERSION=12.17.0
FROM node:${NODE_VERSION}-alpine

# If you have native dependencies, you'll need extra tools
RUN apk add --no-cache make gcc g++ python

# Bash + misc utilities
RUN apk add --no-cache bash curl jq py-pip \
  && pip install awscli

WORKDIR /home/node
USER node

COPY create-dynamodb-tables.sh start-api.sh ./

ENTRYPOINT ["/bin/bash", "start-api.sh"]
