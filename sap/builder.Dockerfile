FROM ubuntu:20.04

ARG HYBRIS_URL

WORKDIR /hybris

RUN apt-get update
RUN apt-get install -y wget unzip openjdk-11-jdk-headless
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64

RUN wget -O hybris.zip -nv $HYBRIS_URL
RUN unzip -q hybris.zip
RUN rm hybris.zip
