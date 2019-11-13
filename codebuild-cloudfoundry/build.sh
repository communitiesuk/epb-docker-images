#!/usr/bin/env bash

git submodule init
docker build -t aws-standard-ubuntu aws-codebuild-docker-images/ubuntu/standard/2.0
docker build -t codebuild-cloudfoundry ./
