#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -rf tmp/pids/server.pid
export NOKOGIRI_USE_SYSTEM_LIBRARIES=1
bundle install -j2
bundle exec rake db:prepare

# Update static content
# Send process to background so we can start the server immediately
./bin/update_static_content.sh &

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
