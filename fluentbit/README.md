# Overview

This image is intended to run as a sidecar on ECS.

It forwards application logs to both CloudWatch and Logit.

## Required parameters

|VAR_NAME | Description |
| - | - |
|`LOG_LEVEL` | `debug` by default |
|`LOG_GROUP_NAME` | should be an existing log group available in the account this is running in |
|`LOG_STREAM_NAME` | CloudWatch stream name |
|`LOGSTASH_HOST` | Should be the "host" found in https://logit.io/sources/configure/logstash/?f=http |
|`LOGSTASH_PORT` | Should be the "port" found in https://logit.io/sources/configure/logstash/?f=http |
