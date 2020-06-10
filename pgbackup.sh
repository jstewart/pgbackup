#!/bin/bash

set -e

# The following environment variables are necessary to run this script:
#
# DBNAME  - The Database to dump
# PG_USER - The username to connect to postgres with
# S3_BUCKET - The name od the S3 bucket we'll be storing the dumps into. Should be a path like s3://bucket-name/
# KEEP_DUMPS - The number of dumps that
#
# Note that S3 authtentication must also be set up according to these instructions:
# https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html
#
# Either a .aws/config and .aws/credentials setup in the cron user's home directory
# or configured via environment variables
# (AWS_SECRET_ACCESS_KEY and AWS_ACCESS_KEY_ID)
#
# Assuming that .pgpass is in the dumping user's home directory

# Ensure that configuration exists
: "${DBNAME?Missing DBNAME}"
: "${PG_USER?Missing PG_USER}"
: "${S3_BUCKET?Missing S3BUCKET}"
: "${KEEP_DUMPS?Missing KEEP_DUMPS}"

# KEEP_DUMPS needs to be a reasonable amount or else we could lose data
re='^[0-9]+$'
if ! [[ $KEEP_DUMPS =~ $re ]] ; then
    echo "KEEP_DUMPS should be numeric"
    exit 1;
fi
if (( $KEEP_DUMPS < 1 )); then
    echo "KEEP_DUMPS needs to be > 0."
    exit 1;
fi

timestamp=$(date '+%Y%m%d%H%M%S')
output_file="/tmp/$DBNAME-$timestamp.tar"

# Create a tarball based dump suitable for pg_restore
pg_dump -h localhost -p 5432 -F t -U $PG_USER -f $output_file $DBNAME
gzip $output_file

aws s3 cp $output_file.gz $S3_BUCKET

deletions=$(aws s3 ls $S3_BUCKET |  awk 'NR>3' | awk '{print $4}')
for f in $deletions
do
    aws s3 rm $S3_BUCKET$f
done

rm $output_file.gz
