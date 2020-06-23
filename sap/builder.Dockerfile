FROM gradle:jdk11

RUN apt-get update
RUN apt-get install -y unzip python3-pip

RUN pip3 install awscli

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_SESSION_TOKEN

ARG S3_HYBRIS_URL

WORKDIR /hybris

RUN echo ${S3_HYBRIS_URL}
RUN curl -s $(aws s3 presign $S3_HYBRIS_URL) > hybris.zip
RUN unzip -q hybris.zip
RUN rm hybris.zip

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

CMD /bin/bash
