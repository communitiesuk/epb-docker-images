#!/bin/bash

set -eu

# check AWS credentials and bucket working
S3_BASE_URI=s3://${S3_BUCKET:?required}

echo "Testing AWS credentials to access ${S3_BASE_URI}"
aws s3 ls "${S3_BASE_URI}/"


datestamp=$(curl -sL http://dilbert.com/ | pup "h1.comic-title a attr{href}" | head -n1 | sed -e "s%^.*/%%")