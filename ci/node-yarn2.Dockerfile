ARG NODE_VERSION=12.18

FROM ns8-docker.jfrog.io/ns8/node-ci:${NODE_VERSION}

# "berry" is the codename for Yarn 2
# Reference: https://yarnpkg.com/getting-started/install
RUN yarn set version berry
