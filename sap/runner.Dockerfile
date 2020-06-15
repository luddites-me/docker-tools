ARG BUILDER_IMAGE

FROM ${BUILDER_IMAGE}

WORKDIR /hybris-connector

RUN apt-get update

COPY ./get-integration-artifact.sh .
RUN bash ./get-integration-artifact.sh hybris-connector.zip
RUN unzip -q hybris-connector.zip

RUN cp -r installer/recipes/* /hybris/installer/recipes/
RUN mkdir -p /hybris/bin/modules
RUN cp -r hybris/bin/modules/* /hybris/hybris/bin/modules/

WORKDIR /hybris

RUN sh ./installer/install.sh -r b2c_acc_plus_ns8 initialize -A initAdminPassword=nimda

CMD sh ./installer/install.sh -r b2c_acc_plus_ns8 start
