#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Update the system
echo "Updating system..."
pacman -Syu --noconfirm

# Install required dependencies
echo "Installing dependencies..."
pacman -S --needed --noconfirm curl git

# Install Nix package manager
echo "Installing Nix package manager..."
sh <(curl -L https://nixos.org/nix/install) --daemon

# Add Nix to the user's PATH
if [[ -f /etc/profile.d/nix.sh ]]; then
    echo "Source the Nix profile in ~/.bashrc"
    echo ". /etc/profile.d/nix.sh" >> ~/.bashrc
fi

# Optional: Enable Nix daemons for user session
# This step is optional, uncomment to enable multi-user support
# sed -i 's/^#multi-user = false/multi-user = true/' /etc/nix/nix.conf

# Optional: Allow untrusted packages to be installed.
# Uncomment if desired, but be cautious!
# echo "substituters = https://cache.nixos.org https://path.to.your.custom.cache" >> /etc/nix/nix.conf
# echo "trusted-public-keys = cache.nixos.org-1:fZ4BXs+lZXq1XYZS9TDUmMfzBiXn5PjHweVtSg11NkY=" >> /etc/nix/nix.conf

# Create Nix user environment
echo "Creating Nix user environment..."
nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
nix-channel --update

# Enable and start Nix daemon
systemctl enable nix-daemon
systemctl start nix-daemon

echo "Nix package manager installed successfully!"

# Add some Nix configuration (optional)
cat <<EOF >> /etc/nix/nix.conf
# Additional Nix configurations can go here
# Enable sandboxing for builds
sandbox = true
EOF

echo "Nix configuration completed. You may want to log out and back in or source your .bashrc."
