#!/usr/bin/env bash

docker build -t aws-standard-ubuntu aws-codebuild-docker/ubuntu/standard/5.0
docker build -t codebuild-cloudfoundry ./
