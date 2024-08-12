# EPB Docker Images

## `aws-ruby-node`

AWS ubuntu standard image with AWS CLI, Ruby and Node.js

This image uses a Dockerfile lifted from the AWS docker images repo.
It used to run tests on AWS Codebuild instance. Dockerfile refers to all dependencies required for running application tests.
Some sections have been removed to speed up the build process.


For more information on the base image please see
[aws docker images github](https://github.com/aws/aws-codebuild-docker-images)

image used to run EPB tests on AWS Codebuild 