## 1. BUILD ARGS
# These allow changing the produced image by passing different build args to adjust
# the source from which your image is built.
# Build args can be provided on the commandline when building locally with:
#   podman build -f Containerfile --build-arg FEDORA_VERSION=40 -t local-image

# SOURCE_IMAGE arg can be anything from ublue upstream which matches your desired version:
# See list here: https://github.com/orgs/ublue-os/packages?repo_name=main
# - "silverblue"
# - "kinoite"
# - "sericea"
# - "onyx"
# - "lazurite"
# - "vauxite"
# - "base"
#
#  "aurora", "bazzite", "bluefin" or "ucore" may also be used but have different suffixes.
ARG SOURCE_IMAGE="bluefin"

## SOURCE_SUFFIX arg should include a hyphen and the appropriate suffix name
# These examples all work for silverblue/kinoite/sericea/onyx/lazurite/vauxite/base
# - "-main"
# - "-nvidia"
# - "-asus"
# - "-asus-nvidia"
# - "-surface"
# - "-surface-nvidia"
#
# aurora, bazzite and bluefin each have unique suffixes. Please check the specific image.
# ucore has the following possible suffixes
# - stable
# - stable-nvidia
# - stable-zfs
# - stable-nvidia-zfs
# - (and the above with testing rather than stable)
ARG SOURCE_SUFFIX="-dx"

## SOURCE_TAG arg must be a version built for the specific image: eg, 39, 40, gts, latest
ARG SOURCE_TAG="gts"

### 2. SOURCE IMAGE
## this is a standard Containerfile FROM using the build ARGs above to select the right upstream image
FROM ghcr.io/ublue-os/${SOURCE_IMAGE}${SOURCE_SUFFIX}:${SOURCE_TAG}

### 3. MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended

## Download Clevis RPMs with TPM 1.2 support
#RUN mkdir /tmp/clevis
#RUN wget -qO- https://api.github.com/repos/oldium/clevis/releases/tags/v21_tpm1u3 | jq -r '.assets[].browser_download_url | select(test("fc40"))' | wget -ci- && mv clevis*.rpm /tmp/clevis
#RUN find /tmp/clevis

# Download VmWare Horizon client
RUN curl -Lo https://download3.omnissa.com/software/CART25FQ2_LIN64_RPMPKG_2406/VMware-Horizon-Client-2406-8.13.0-9995429239.x64.rpm /tmp/rpms/VMware-Horizon-Client-2406-8.13.0-9995429239.x64.rpm

## Add displaylink support
COPY --from=ghcr.io/ublue-os/akmods-extra:coreos-stable-40 /rpms/ /tmp/rpms
RUN curl -Lo /etc/yum.repos.d/fedora-multimedia.repo https://negativo17.org/repos/fedora-multimedia.repo

## Add Copr repo for howdy support
RUN curl -Lo /etc/yum.repos.d/howdy-copr.repo https://copr.fedorainfracloud.org/coprs/principis/howdy-beta/repo/fedora-40/principis-howdy-beta-fedora-40.repo
RUN find /tmp/rpms

COPY build.sh /tmp/build.sh
RUN mkdir -p /var/lib/alternatives && \
    /tmp/build.sh && \
    ostree container commit
## NOTES:
# - /var/lib/alternatives is required to prevent failure with some RPM installs
# - All RUN commands must end with ostree container commit
#   see: https://coreos.github.io/rpm-ostree/container/#using-ostree-container-commit
