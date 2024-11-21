#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root!"
   exit 1
fi

# Function to print usage
usage() {
    echo "Usage: $0 new-hostname"
    exit 1
}

# Check if a hostname is provided
if [ -z "$1" ]; then
    usage
fi

# Set the new hostname
NEW_HOSTNAME=$1

# Change the hostname on the host OS
echo "Changing the hostname of the host OS to $NEW_HOSTNAME..."
hostnamectl set-hostname "$NEW_HOSTNAME"

# Update /etc/hosts on the host OS
sed -i "s/127.0.1.1.*/127.0.1.1   $NEW_HOSTNAME/" /etc/hosts

# Add hostname to /etc/hosts if not present
if ! grep -q "$NEW_HOSTNAME" /etc/hosts; then
    echo "127.0.1.1   $NEW_HOSTNAME" >> /etc/hosts
fi

echo "Hostname changed successfully to $NEW_HOSTNAME on the host OS."

# Link host OS hostname to Docker container's /etc/hostname
echo "Linking the host's /etc/hostname to the Docker container..."
ln -sf /etc/hostname /var/lib/docker/containers/$(docker ps -q)/hostname

echo "Symlink created! The Docker container will now reflect the host's hostname."

# Confirm the changes
echo "The current hostname is: $(hostname)"
