FROM gradle:jdk11

# aws creds to sign S3 url with
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_SESSION_TOKEN
# the raw S3 url, which we then sign
ARG S3_HYBRIS_URL

# install unzip & pip
RUN apt-get update
RUN apt-get install -y unzip python3-pip

# install AWS CLI from pip (because apt's version is usually very out of date)
RUN pip3 install awscli

WORKDIR /hybris

# download Hybris zip from S3
RUN echo ${S3_HYBRIS_URL}
RUN curl -s $(aws s3 presign $S3_HYBRIS_URL) > hybris.zip

RUN unzip -q hybris.zip
RUN rm hybris.zip

CMD /bin/bash
