#
# UniFi Protect Dockerfile
# Copyright (C) 2019 James T. Lee
#

#This is a forked version of James T. Lee's code, who is the copyright holder. His code was modified to create a version for ARM64 on the UDM base.

FROM --platform=linux/arm64 ubuntu:bionic

# Install build tools
RUN apt-get update \
 && apt-get install -y wget

# Install unifi-protect and its dependencies
RUN wget --progress=dot:mega https://apt.ubnt.com/pool/beta/u/unifi-protect/unifi-protect.jessie~stretch~xenial~bionic_arm64.v1.13.0-beta.16.deb -O unifi-protect.deb \
 && dpkg --ignore-depends -i ./unifi-protect.deb \
 && rm -f unifi-protect.deb

# Cleanup
RUN apt-get remove --purge --auto-remove -y wget \
 && rm -rf /var/cache/apt/lists/*

# Initialize based on /usr/share/unifi-protect/app/hooks/pre-start
RUN pg_ctlcluster 10 main start \
 && su postgres -c 'createuser unifi-protect -d' \
 && pg_ctlcluster 10 main stop \
 && ln -s /srv/unifi-protect/logs /var/log/unifi-protect \
 && mkdir /srv/unifi-protect /srv/unifi-protect/backups /var/run/unifi-protect \
 && chown unifi-protect:unifi-protect /srv/unifi-protect /srv/unifi-protect/backups /var/run/unifi-protect \
 && ln -s /tmp /srv/unifi-protect/temp

# Add repo for future updates
#&& add-apt-repository 'deb http://apt.ubnt.com bionic main'
#&& apt-key adv --keyserver keyserver.ubuntu.com --recv 97B46B8582C6571E

# Configure
COPY config.json /etc/unifi-protect/config.json

# Supply simple script to run postgres and unifi-protect
COPY init /init
CMD ["/init"]
