#!/usr/bin/env bash
# Script Name: backup-restore-postgres.sh
# Description: This script provides a simple way to backup and restore a PostgreSQL database running inside a Docker container..
# Maintainer: Ithadev Ng <ithadev.nguyen@gmail.com>
# Last Updated: 2025-03-11
# Version: 0.1

## Configuration
# 1. Environment Variables:
#   - Copy the `.env.example` file to `.env`:
#   - Edit the `.env` file and set the appropriate values for your environment.
#
# 2. Command-line Flags (Optional):
#   You can override the environment variables by using command-line flags.
#   - `--container-name`: Name of the Docker container running PostgreSQL.
#   - `--container-port`: Port the container exposes for PostgreSQL.
#   - `--db`: Name of the PostgreSQL database.
#   - `--user`: PostgreSQL username.
#   - `--password`: PostgreSQL password.
#   - `--host`: PostgreSQL host (usually `localhost` or the container's IP).
#   - `--port`: PostgreSQL port (usually `5432`).
#   - `--dump-file`: Path to the dump file.
#
## Usage
# To create a backup of your database:
#
#           ./backup_restore.sh backup
#
# Or, with flags to override environment variables:
#
#   ./backup_restore.sh backup --db my_other_db --dump-file /backups/other_db.sql
#
# To restore a database from a backup:
#
#           ./backup_restore.sh restore
#
# Or, with flags:
#
#   ./backup_restore.sh restore --db my_new_db --dump-file /backups/old_db.sql
#
## TODO
# Features todo (or never do :/)
# - Add options for compressed backups to save space.
# - Scheduling capabilities (e.g., using `cron`) for automated backups.
# - Consider adding encryption for the backup files for enhanced security.
# - Implement a retention policy to manage old backups.
# - Add more detailed error messages for specific `pg_dump`/`pg_restore` failures.
# - Add a `--dry-run` option to preview the backup/restore commands without executing them.
# - Add support for multiple database backups in a single run.
# - Adding tests to verify the backup and restore functionality.

# Function to display pretty log messages
log_message() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Load environment variables from .env file
if [ -f .env ]; then
  export "$(grep -v '^#' .env | xargs)"
fi

# Default values (can be overridden by .env or flags)
CONTAINER_NAME=${CONTAINER_NAME:-postgres_container}
CONTAINER_PORT=${CONTAINER_PORT:-5432}
POSTGRES_DB=${POSTGRES_DB:-mydatabase}
POSTGRES_USER=${POSTGRES_USER:-postgres}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-password}
POSTGRES_HOST=${POSTGRES_HOST:-localhost}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
DUMP_FILE_PATH=${DUMP_FILE_PATH:-/tmp/backup.sql}

# Parse command-line flags
while [[ $# -gt 0 ]]; do
  case "$1" in
  --container-name)
    CONTAINER_NAME="$2"
    shift 2
    ;;
  --container-port)
    CONTAINER_PORT="$2"
    shift 2
    ;;
  --db)
    POSTGRES_DB="$2"
    shift 2
    ;;
  --user)
    POSTGRES_USER="$2"
    shift 2
    ;;
  --password)
    POSTGRES_PASSWORD="$2"
    shift 2
    ;;
  --host)
    POSTGRES_HOST="$2"
    shift 2
    ;;
  --port)
    POSTGRES_PORT="$2"
    shift 2
    ;;
  --dump-file)
    DUMP_FILE_PATH="$2"
    shift 2
    ;;
  *)
    ACTION="$1"
    shift
    ;;
  esac
done

# Validate action
if [ "$ACTION" != "backup" ] && [ "$ACTION" != "restore" ]; then
  log_message "ERROR: Invalid action. Please specify 'backup' or 'restore'."
  exit 1
fi

# Validate required variables
if [ -z "$CONTAINER_NAME" ] || [ -z "$POSTGRES_DB" ] || [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_PASSWORD" ] || [ -z "$DUMP_FILE_PATH" ]; then
  log_message "ERROR: One or more required variables are not set. Please check .env file or use flags."
  exit 1
fi

# Backup function
backup_db() {
  log_message "Starting backup of database '$POSTGRES_DB'..."
  docker exec "$CONTAINER_NAME" pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -Fc >"$DUMP_FILE_PATH"
  if [ $? -eq 0 ]; then
    log_message "Backup completed successfully. Dump file: $DUMP_FILE_PATH"
  else
    log_message "ERROR: Backup failed."
    exit 1
  fi
}

# Restore function
restore_db() {
  log_message "Starting restore of database '$POSTGRES_DB'..."
  docker exec -i "$CONTAINER_NAME" pg_restore -U "$POSTGRES_USER" -d "$POSTGRES_DB" -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -Fc <"$DUMP_FILE_PATH"
  if [ $? -eq 0 ]; then
    log_message "Restore completed successfully."
  else
    log_message "ERROR: Restore failed."
    exit 1
  fi
}
# Set the password in environment for docker to avoid prompt
export PGPASSWORD=$POSTGRES_PASSWORD

# Perform the selected action
if [ "$ACTION" == "backup" ]; then
  backup_db
elif [ "$ACTION" == "restore" ]; then
  restore_db
fi

log_message "Operation '$ACTION' finished."
exit 0
