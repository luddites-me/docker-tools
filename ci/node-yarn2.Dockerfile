ARG NODE_VERSION=12.18

FROM luddites-docker.jfrog.io/luddites/node-ci:${NODE_VERSION}

# "berry" is the codename for Yarn 2
# Reference: https://yarnpkg.com/getting-started/install
RUN yarn set version berry
