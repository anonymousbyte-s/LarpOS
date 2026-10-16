#!/bin/bash

# arguments: $RELEASE $LINUXFAMILY $BOARD $BUILD_DESKTOP
#
# This is the image customization script

# NOTE: It is copied to /tmp directory inside the image
# and executed there inside chroot environment
# so don't reference any files that are not already installed

# NOTE: If you want to transfer files between chroot and host
# userpatches/overlay directory on host is bind-mounted to /tmp/overlay in chroot
# The sd card's root path is accessible via $SDCARD variable.

# stop the script on any erorrs
set -e

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

# this will copy all of the config files to the build env
copyConfigs() {
    # copy the sway config
    install -D -m 644 /tmp/overlay/etc/skel/.config/sway/config /etc/skel/.config/sway/config

    # copy the greetd config
    install -D -m 644 /tmp/overlay/etc/greetd/config.toml /etc/greetd/config.toml
    # copy the tuigreet config
    install -D -m 644 /tmp/overlay/etc/tuigreet/config.toml /etc/tuigreet/config.toml
}

Main() {
    echo "Buidling for $BOARD with chip $LINUXFAMILY version $RELEASE"

    # update the system packages
    apt-get update

    # install packages
    sudo apt install -y sway \
    waybar \
    swaylock \
    tuigreet \
    greetd

    # Clean up the apt cache to keep your final image smaller
    apt-get clean

    # copy the config files
    copyConfigs;

    # Create a system user without a home directory, added to the video group
    # this user is for the greetd service
    sudo useradd -M -G video greeter

    # Ensure the greeter user can read the configuration directory
    sudo chmod -R go+r /etc/greetd/

    # enable the greetd service
    systemctl enable greetd
}

Main "$@"
