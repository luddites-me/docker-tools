FROM ubuntu:latest

RUN mkdir /hybris
WORKDIR /hybris

RUN apt-get update
RUN apt-get install -y wget unzip openjdk-11-jre

RUN wget -nv http://host.docker.internal:8085/hybris.zip
RUN unzip hybris.zip
RUN rm hybris.zip

ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64

RUN mkdir /hybris-connector
WORKDIR /hybris-connector

COPY ./hybris-connector.zip ./
RUN unzip hybris-connector.zip

RUN cp -r installer/recipes/* /hybris/installer/recipes/
RUN mkdir -p /hybris/bin/modules
RUN cp -r hybris/bin/modules/* /hybris/hybris/bin/modules/

WORKDIR /hybris

RUN sh ./installer/install.sh -r b2c_acc_plus_ns8 initialize -A initAdminPassword=nimda

CMD sh ./installer/install.sh -r b2c_acc_plus_ns8 start
