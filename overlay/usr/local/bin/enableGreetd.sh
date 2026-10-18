#!/usr/bin/env bash

# wait until the user logs in for the first time
until [ ! -e /root/.not_logged_in_yet ]; do sleep 1; done
# enable the greetd service
systemctl enable greetd.service
# start the greetd service
systemctl restart greetd.service
# disable the service that ran this script
systemctl disable enableGreetd.service
