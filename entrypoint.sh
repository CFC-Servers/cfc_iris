#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
#rm -f /factions-backend/tmp/pids/server.pid

#exec bundle exec rake db:prepare

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
