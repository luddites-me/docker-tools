#!/bin/sh

IMAGE_NAME="244249143763.dkr.ecr.us-west-2.amazonaws.com/protect-integration-hybris-dev-ah"

echo "Warning: this will take >40 minutes to build!"

sleep 3

python3 -m http.server 8085 &

docker build -t hybris -t "$IMAGE_NAME" .

docker tag hybris "$IMAGE_NAME"

kill $!
