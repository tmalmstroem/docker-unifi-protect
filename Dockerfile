#
# UniFi Protect Dockerfile
# Copyright (C) 2019 James T. Lee
#

#This is a forked version of James T. Lee's code, who is the copyright holder. His code was modified to create a version for ARM64 on the UDM base.

FROM ubuntu:18.04

# Install build tools
RUN apt-get update \
 && apt-get install -y wget

# Install unifi-protect and its dependencies
RUN wget --progress=dot:mega https://apt.ubnt.com/pool/beta/u/unifi-protect/unifi-protect.jessie~stretch~xenial~bionic_arm64.v1.13.0-beta.16.deb -O unifi-protect.deb \
 && apt install -y ./unifi-protect.deb \
 && rm -f unifi-protect.deb

# Cleanup
RUN apt-get remove --purge --auto-remove -y wget \
 && rm -rf /var/cache/apt/lists/*

# Initialize based on /usr/share/unifi-protect/app/hooks/pre-start
RUN pg_ctlcluster 10 main start \
 && su postgres -c 'createuser unifi-protect -d' \
 && pg_ctlcluster 10 main stop \
 && mkdir /mnt/data/unifi-protect /mnt/data/unifi-protect/backups /mnt/data/unifi-protect/run \
 && chown unifi-protect:unifi-protect /mnt/data/unifi-protect /mnt/data/unifi-protect/backups /mnt/data/unifi-protect/logs /mnt/data/unifi-protect/run \
 && ln -s /tmp /mnt/data/unifi-protect/temp

# Configure
COPY config.json /mnt/data/unifi-protect/config.json

# Supply simple script to run postgres and unifi-protect
COPY init /init
CMD ["/init"]
