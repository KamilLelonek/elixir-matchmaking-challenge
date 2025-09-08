#!/bin/sh
set -e

# Ensure the app's dependencies are installed
mix deps.get
mix deps.compile

echo "\nTesting the installation..."
# "Proove" that install was successful by running the tests
mix test

echo "\n Launching Phoenix web server..."
# Start the phoenix web server
mix phx.server
