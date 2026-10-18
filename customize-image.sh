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
    # copy the sway background
    install -D -m 644 /tmp/overlay/usr/share/backgrounds/wallpaper.jpg /usr/share/backgrounds/wallpaper.jpg
    # copy the greetd config
    install -D -m 644 /tmp/overlay/etc/greetd/config.toml /etc/greetd/config.toml
    # copy the tuigreet config
    install -D -m 644 /tmp/overlay/etc/tuigreet/config.toml /etc/tuigreet/config.toml
}

copyBins() {
    # install the tuigreet binary
    install -D -m 755 /tmp/overlay/usr/local/bin/tuigreet /usr/local/bin/tuigreet
}

copyServices() {
    # copy the service that enables and starts the greetd service after the first boot and login
    install -D -m 744 /tmp/overlay/etc/systemd/system/enableGreetd.service /etc/systemd/system/enableGreetd.service
    # enable the service
    systemctl enable enableGreetd.service
}

Main() {
    echo "Buidling for $BOARD with chip $LINUXFAMILY version $RELEASE"

    # update the system packages
    apt-get update

    # install packages
    apt-get install -y sway \
    libxcb-dri2-0 \
    swaylock \
    fuzzel \
    firefox-esr \
    foot \
    thunar \
    greetd

    # Clean up the apt cache
    apt-get clean

    # copy the config files
    copyConfigs;

    # copy the binaries
    copyBins;

    copyServices;

    # Create a system user without a home directory, added to the video group
    # this user is for the greetd service
    useradd --system --no-create-home --shell /usr/sbin/nologin --groups video greeter

    # disable the greeter user password login
    passwd --lock greeter

    # Ensure the greeter user can read the configuration directory
    chmod -R go+r /etc/greetd/
}

Main "$@"
