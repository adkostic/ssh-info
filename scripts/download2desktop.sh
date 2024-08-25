#!/bin/bash
# Usage: download_to_desktop.sh <file_path>

REMOTE_FILE_PATH=$1
LOCAL_USERNAME="adk"

# Hostname or fixed IP address
LOCAL_HOSTNAME="ADK-M3-Max.local"

# Local destination directory
LOCAL_DEST_DIR="/Users/$LOCAL_USERNAME/Desktop/"

# Perform the file transfer
scp -r $REMOTE_FILE_PATH $LOCAL_USERNAME@$LOCAL_HOSTNAME:$LOCAL_DEST_DIR

echo "File(s) successfully downloaded to $LOCAL_DEST_DIR"
