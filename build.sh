#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"


### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images

# Override clevis and clevis-luks from base in favour of own fork with TPM1.2 support
#rpm-ostree override replace /tmp/clevis/clevis-21-1.tpm1u3.fc40.x86_64.rpm /tmp/clevis/clevis-luks-21-1.tpm1u3.fc40.x86_64.rpm

# Install thinkfan, tlp, igt-gpu-tools and displaylink kernel module, as well as (temporary) clevis dependencies
#rpm-ostree install tlp thinkfan igt-gpu-tools /tmp/rpms/kmods/*evdi*.rpm /tmp/clevis/clevis-dracut-21-1.tpm1u3.fc40.x86_64.rpm /tmp/clevis/clevis-systemd-21-1.tpm1u3.fc40.x86_64.rpm
rpm-ostree install /tmp/rpms/kmods/*evdi*.rpm howdy howdy-gtk sbsigntools systemd-ukify
rpm-ostree install /tmp/misc/*.rpm
tar -C / --no-same-owner -m -h -vxzf /tmp/misc/linux-enable-ir-emitter-6.0.6.systemd.x86-64.tar.gz

# Disable negativo repo after installing displaylink, as it otherwise conflicts with RPM-fusion, and disable howdy too, for good measure
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-multimedia.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/howdy-copr.repo 

# Mask power-profiles-daemon in order for tlp to work correctly
#systemctl mask power-profiles-daemon.service
