#!/bin/sh
set -e

: "${DISCORD_BOT_TOKEN:?DISCORD_BOT_TOKEN is required but not set}"

exec "$@"
