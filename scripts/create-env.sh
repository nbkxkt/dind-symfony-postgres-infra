#!/bin/sh
set -eu
cd "$(dirname "$0")/.."

if [ -e .env ]; then
    printf '%s\n' 'infra/.env already exists; leaving it unchanged.' >&2
    exit 1
fi

umask 077
app_secret=$(od -An -N32 -tx1 /dev/urandom | tr -d ' \n')
db_password=$(od -An -N32 -tx1 /dev/urandom | tr -d ' \n')
{
    printf 'APP_SECRET=%s\n' "$app_secret"
    printf 'POSTGRES_DB=dind_demo\n'
    printf 'POSTGRES_USER=dind_demo\n'
    printf 'POSTGRES_PASSWORD=%s\n' "$db_password"
} > .env
chmod 600 .env
unset app_secret db_password
printf '%s\n' 'Created private infra/.env in the current checkout. Do not add or commit it.'
