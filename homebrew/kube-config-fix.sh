#!/bin/sh
set -e

# Define the user and target config file
USER=toolbox
HOME=/home/$USER
KUBE_CONFIG="$HOME/.kube/config"

# Check if we are running as root
if [ "$(id -u)" = "0" ]; then
    # If the kubeconfig exists
    if [ -f "$KUBE_CONFIG" ]; then
        FILE_UID=$(stat -c '%u' "$KUBE_CONFIG")
        FILE_GID=$(stat -c '%g' "$KUBE_CONFIG")

        # CASE 1: File is owned by root (UID 0)
        # We cannot change our user to root (we want to stay as toolbox), so we must copy the file.
        if [ "$FILE_UID" = "0" ]; then
            echo "Detected root-owned kubeconfig. Copying to temporary location for read access..."
            mkdir -p /tmp/.kube
            cp "$KUBE_CONFIG" /tmp/.kube/config
            chown -R $USER:$USER /tmp/.kube
            export KUBECONFIG=/tmp/.kube/config
            echo "Set KUBECONFIG=$KUBECONFIG"
            
        # CASE 2: File is owned by a non-root user (e.g. 1000)
        # We should adjust the 'toolbox' user ID to match this user so we can access it naturally.
        elif [ "$FILE_UID" != "$(id -u $USER)" ]; then
            echo "Detected kubeconfig owned by UID $FILE_UID. Adjusting '$USER' UID to match..."
            
            # Change UID of the user
            # -o allows non-unique if necessary, though we usually avoid it.
            usermod -u "$FILE_UID" -o $USER
            
            # Also try to update the group if possible, but it's secondary
            # groupmod -g "$FILE_GID" -o $USER || true

            # Fix ownership of the home directory files we copied in during build
            chown -R $USER:$USER $HOME
        fi
    fi

    # Execute the command as the toolbox user
    exec gosu $USER "$@"
else
    # If we are already running as non-root, just execute
    exec "$@"
fi
