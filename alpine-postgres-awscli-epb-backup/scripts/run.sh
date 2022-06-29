#!/bin/bash

set -eu

now=$(date)

echo "Date container stared is: $now"
# check AWS credentials and bucket working
S3_BASE_URI=s3://${S3_BUCKET:?required}

echo "Testing AWS credentials to access ${S3_BASE_URI}"
aws s3 ls "${S3_BASE_URI}/"

