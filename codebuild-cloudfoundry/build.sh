#!/usr/bin/env bash

docker build -t aws-standard-ubuntu aws-codebuild-docker/ubuntu/standard/2.0
docker build -t codebuild-cloudfoundary ./
