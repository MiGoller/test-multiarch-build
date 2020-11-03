FROM ubuntu:20.04

# Build arguments ...

# S6-Overlay version
ARG ARG_S6_OVERLAY_VERSION="2.1.0.2"

# The commit sha triggering the build.
ARG ARG_APP_COMMIT

# BuildX ...
ARG TARGETPLATFORM
ARG BUILDPLATFORM

# Basic build-time metadata as defined at http://label-schema.org
LABEL \
    org.label-schema.docker.dockerfile="/Dockerfile" \
    org.label-schema.license="MIT" \
    org.label-schema.name="MiGoller" \
    org.label-schema.vendor="MiGoller" \
    org.label-schema.version="0.1.0" \
    org.label-schema.description="Multi-Arch Test Build" \
    org.label-schema.url="https://github.com/MiGoller/test-multiarch-build" \
    org.label-schema.vcs-type="Git" \
    org.label-schema.vcs-ref="${ARG_APP_COMMIT}" \
    org.label-schema.vcs-url="https://github.com/MiGoller/test-multiarch-build.git" \
    maintainer="MiGoller" \
    Author="MiGoller" \
    org.opencontainers.image.source="https://github.com/MiGoller/test-multiarch-build"

# Default environment variables
ENV \
    DEBIAN_FRONTEND="noninteractive" \
    S6_OVERLAY_VERSION=${ARG_S6_OVERLAY_VERSION}

# Install prerequisites
RUN \
    # Install prerequisites
    apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        tar \
    # Clean up installation cache
    && rm -rf /var/lib/apt/lists/*

# Install S6-Overlay
RUN \
    # Determine S6 arch to download and to install
    S6_ARCH="" \
    && dpkgArch="$(dpkg --print-architecture)" \
    && case "${dpkgArch##*-}" in \
        amd64) S6_ARCH='amd64';; \
        ppc64el) S6_ARCH='ppc64le';; \
        arm64) S6_ARCH='armhf';; \
        arm) S6_ARCH='arm';; \
        armel) S6_ARCH='arm';; \
        armhf) S6_ARCH='armhf';; \
        i386) S6_ARCH='x86';; \
        *) echo "Unsupported architecture for S6: ${dpkgArch}"; exit 1 ;; \ 
    esac \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${ARG_S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.gz" \
        | tar zxvf - -C / \
    && mkdir -p /etc/fix-attrs.d \
    && mkdir -p /etc/services.d \
    && echo "S6 Overlay v${ARG_S6_OVERLAY_VERSION} (${S6_ARCH} for dpkArch ${dpkgArch}) installed on ${BUILDPLATFORM} for ${TARGETPLATFORM}."

# Set container entrpoint to S6-Overlay!
ENTRYPOINT ["/init"]
