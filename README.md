# EPB Docker Images

## `aws-ruby-node`

AWS ubuntu standard image with AWS CLI, Ruby and Node.js

This image uses a Dockerfile lifted from the AWS docker images repo.
It used to run tests on AWS Codebuild instance. Dockerfile refers to all dependencies required for running application tests.
Some sections have been removed to speed up the build process.


For more information on the base image please see
[aws docker images github](https://github.com/aws/aws-codebuild-docker-images)

## `fluentbit`

This image is intended to run as a sidecar on ECS.

It forwards application logs to both CloudWatch and Logit.

### Required parameters

|VAR_NAME | Description |
| - | - |
|`LOG_LEVEL` | `debug` by default |
|`LOG_GROUP_NAME` | should be an existing log group available in the account this is running in |
|`LOG_STREAM_NAME` | CloudWatch stream name |
|`LOGSTASH_HOST` | Should be the "host" found in https://logit.io/sources/configure/logstash/?f=http |
|`LOGSTASH_PORT` | Should be the "port" found in https://logit.io/sources/configure/logstash/?f=http |


## `postgres`

Base postgres image used to run tests on AWS Codebuild 