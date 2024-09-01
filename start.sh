#!/bin/bash

# Set variables to use the current directory
CURRENT_DIR="$(pwd)"
GATUS_BINARY="$CURRENT_DIR/gatus"  # Gatus binary will be downloaded here
CONFIG_URL="${CONFIG_URL:-}"  # Make sure to set this environment variable before running the script
LOCAL_CONFIG="$CURRENT_DIR/config/config.yaml"  # Local config file will be stored here
PID_FILE="$CURRENT_DIR/gatus.pid"  # File to store the PID of the running Gatus process

# Create the config directory if it doesn't exist
mkdir -p "$(dirname "$LOCAL_CONFIG")"

# Function to check if necessary variables are set
check_variables() {
  if [ -z "$CONFIG_URL" ]; then
    echo "$(date '+%Y/%m/%d %H:%M:%S') [boot] Error: CONFIG_URL is not set. Please set the URL to the Gatus configuration file."
    exit 1
  fi
}

# Function to download Gatus binary if not found
download_gatus() {
  echo "$(date '+%Y/%m/%d %H:%M:%S') [boot] Gatus binary not found. Downloading..."
  curl -s -L -O https://github.com/devolart/gatus-auto-update/releases/download/1.0/gatus
  if [ ! -f "$GATUS_BINARY" ]; then
    echo "$(date '+%Y/%m/%d %H:%M:%S') [boot] Error: Failed to download Gatus binary."
    exit 1
  fi
  echo "$(date '+%Y/%m/%d %H:%M:%S') [boot] Gatus binary downloaded to $GATUS_BINARY."
}

# Function to start Gatus
start_gatus() {
  echo "$(date '+%Y/%m/%d %H:%M:%S') [boot] Starting Gatus..."
  chmod +x $GATUS_BINARY
  "$GATUS_BINARY" &
  echo $! > "$PID_FILE"
}

# Function to stop Gatus
stop_gatus() {
  if [ -f "$PID_FILE" ]; then
    echo "$(date '+%Y/%m/%d %H:%M:%S') [boot] Stopping Gatus..."
    kill "$(cat "$PID_FILE")"
    rm "$PID_FILE"
  fi
}

# Run the variable check function
check_variables

# Check if Gatus binary exists, otherwise download it
if [ ! -x "$GATUS_BINARY" ]; then
  download_gatus
fi

# Initial configuration download and start Gatus
curl -s -o "$LOCAL_CONFIG" "${CONFIG_URL}?cache-bypass=$(date +%s)"
start_gatus

# Infinite loop to check for config changes every minute
while true; do
  sleep 60
  # Download new config to a temporary file
  curl -s -o "$CURRENT_DIR/config_new.yaml" "${CONFIG_URL}?cache-bypass=$(date +%s)"

  # Compare new config with the current one
  if ! cmp -s "$CURRENT_DIR/config_new.yaml" "$LOCAL_CONFIG"; then
    echo "$(date '+%Y/%m/%d %H:%M:%S') [auto.update] Configuration has changed. Updating..."
    # Stop Gatus, update the config, and restart Gatus
    stop_gatus
    mv "$CURRENT_DIR/config_new.yaml" "$LOCAL_CONFIG"
    start_gatus
  else
    echo "$(date '+%Y/%m/%d %H:%M:%S') [auto.update] No change in configuration"
  fi

  # Clean up temporary file
  rm "$CURRENT_DIR/config_new.yaml"
done
