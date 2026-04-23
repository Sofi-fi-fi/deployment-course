#!/bin/bash

set -e

CONFIG_PATH="/etc/mywebapp/config.json"

echo "Using config: $CONFIG_PATH"

if [ ! -f "$CONFIG_PATH" ]; then
    echo "ERROR: config not found: $CONFIG_PATH"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "ERROR: jq is not installed. Run: apt install jq"
    exit 1
fi

if ! command -v psql &> /dev/null; then
    echo "ERROR: psql is not installed. Run: apt install postgresql-client"
    exit 1
fi

CONN_STR=$(jq -r '.ConnectionStrings.DefaultConnection' "$CONFIG_PATH")

if [ -z "$CONN_STR" ] || [ "$CONN_STR" = "null" ]; then
    echo "ERROR: ConnectionStrings.DefaultConnection is missing in config"
    exit 1
fi

parse_param() {
    echo "$CONN_STR" | tr ';' '\n' | grep -i "^$1=" | cut -d'=' -f2
}

DB_HOST=$(parse_param "Host")
DB_PORT=$(parse_param "Port")
DB_NAME=$(parse_param "Database")
DB_USER=$(parse_param "Username")
DB_PASS=$(parse_param "Password")

SQL="
CREATE TABLE IF NOT EXISTS tasks (
    id         SERIAL PRIMARY KEY,
    title      TEXT        NOT NULL,
    status     TEXT        NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
"

echo "Connecting to PostgreSQL..."

export PGPASSWORD="$DB_PASS"

echo "Creating tasks table..."

psql \
    --host="$DB_HOST" \
    --port="$DB_PORT" \
    --username="$DB_USER" \
    --dbname="$DB_NAME" \
    --command="$SQL"

echo "Migration completed successfully."