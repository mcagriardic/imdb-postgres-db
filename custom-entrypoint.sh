#!/bin/bash
set -e

# Run the original entrypoint script
docker-entrypoint.sh postgres &

# Wait for PostgreSQL to be ready
until pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"; do
  echo "Waiting for PostgreSQL to be ready..."
  sleep 2
done

# Drop existing tables if they exist
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<-EOSQL
    DROP TABLE IF EXISTS name_basics, title_akas, title_basics, title_crew, title_episode, title_principals, title_ratings CASCADE;
EOSQL

# Run init.sql to create tables
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /docker-entrypoint-initdb.d/init.sql

# Set PostgreSQL configuration for bulk import
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<-EOSQL
    ALTER SYSTEM SET max_wal_size = '8GB';
    ALTER SYSTEM SET checkpoint_timeout = '30min';
    ALTER SYSTEM SET checkpoint_completion_target = 0.9;
    ALTER SYSTEM SET maintenance_work_mem = '1GB';
    ALTER SYSTEM SET max_parallel_workers_per_gather = 4;
    ALTER SYSTEM SET max_parallel_workers = 8;
    ALTER SYSTEM SET work_mem = '64MB';
    SELECT pg_reload_conf();
EOSQL

# Run import_data.sh
/docker-entrypoint-initdb.d/import_data.sh

# Reduce the hardware used if necessary.
# Reset PostgreSQL configuration to more normal values
# psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<-EOSQL
#     ALTER SYSTEM SET max_wal_size = '1GB';
#     ALTER SYSTEM SET checkpoint_timeout = '5min';
#     ALTER SYSTEM SET maintenance_work_mem = '64MB';
#     ALTER SYSTEM SET max_parallel_workers_per_gather = 2;
#     ALTER SYSTEM SET max_parallel_workers = 8;
#     ALTER SYSTEM SET work_mem = '4MB';
#     SELECT pg_reload_conf();
# EOSQL


echo "Running post_import.sql..."

# Run post_import.sql
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /docker-entrypoint-initdb.d/post_import.sql

echo "Succesfully ran post_import.sql!"

# Wait for the original entrypoint process
wait $!