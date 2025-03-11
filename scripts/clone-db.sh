#!/bin/bash

# This script use to clone the main database in local for PostgreSQL
# Create a new clone database from this main database for test
# This script always force to override exists database clone
# How work?
# Step 1: exec to container postgreSQL
# Step 2: Clone database using SQL Query: CREATE DATABASE lab WITH TEMPLATE admin OWNER admin;

# Define the main database
db_main_name='admin'

# Define the new cloned database
db_clone_name='lab'

# Define the user that will own the cloned database
db_owner='admin'

# Define the container where the PostgreSQL is running
container_name='postgres-db-test'

docker exec -i $container_name psql -U backend -d postgres <<-EOSQL
    -- Clone the database
    DROP DATABASE IF EXISTS $db_clone_name;
    CREATE DATABASE $db_clone_name WITH TEMPLATE $db_main_name OWNER $db_owner;
EOSQL
