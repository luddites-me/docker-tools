ARG BUILDER_IMAGE

FROM ${BUILDER_IMAGE}

WORKDIR /hybris-connector

# copy local connector (if it exists) and downloader script
COPY ./*hybris-connector.zip ./get-integration-artifact.sh ./
# grab the latest release from protect-integration-sap repo
RUN bash ./get-integration-artifact.sh hybris-connector.zip
RUN unzip -q hybris-connector.zip

RUN cp -r installer/recipes/* /hybris/installer/recipes/
RUN mkdir -p /hybris/bin/modules
RUN cp -r hybris/bin/modules/* /hybris/hybris/bin/modules/

WORKDIR /hybris

ARG INITIAL_ADMIN_PASSWORD=nimda

RUN sh ./installer/install.sh -r b2c_acc_plus_ns8 initialize -A initAdminPassword=$INITIAL_ADMIN_PASSWORD

CMD sh ./installer/install.sh -r b2c_acc_plus_ns8 start
