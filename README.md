# PostgreSQL backup script

Prerequisites:

Postgresql client utilities must be installed

macOS:

    brew install libpq 
    brew link --force libpq ail
    
Linux (debian-like):

    apt-get update && apt-get install postgresql-client


Aws cli

See https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html for details. This script assumes that the CLI is set up.

Set up the database (may need to adjust ports in docker-compose.yml):


    docker-compose up -d
    
    cp pgpass ~/.pgpass && chmod 600 ~/pgpass 
    psql -h localhost -p 5432 -U mypguser
    mypguser=# create database users;
    CREATE DATABASE

    psql -h localhost -p 5432 -U mypguser < users.sql 


Run the script:

    DBNAME=users PG_USER=mypguser S3_BUCKET=(your s3 bucket) KEEP_DUMPS=3 ./pgbackup.sh
