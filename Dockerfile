FROM debian:latest

COPY etc/ssh/* /etc/ssh/

# Install required dependencies
RUN apt-get update \
    && apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        wget \
        curl \
        jq \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove -y \
    && apt-get clean -y

# Detect architecture and download the latest miniserve
RUN ARCH=$(uname -m) && \
    # Map common architectures to miniserve's naming convention
    case "$ARCH" in \
        "x86_64") TARGET="x86_64-unknown-linux-gnu" ;; \
        "aarch64") TARGET="aarch64-unknown-linux-gnu" ;; \
        "armv7l") TARGET="armv7-unknown-linux-musleabihf" ;; \
        "armv6l") TARGET="arm-unknown-linux-musleabihf" ;; \
        "riscv64") TARGET="riscv64gc-unknown-linux-gnu" ;; \
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;; \
    esac && \
    # Fetch the latest release version from GitHub API (strip 'v' prefix if present)
    LATEST_VERSION=$(curl -s "https://api.github.com/repos/svenstaro/miniserve/releases/latest" | jq -r '.tag_name | ltrimstr("v")') && \
    # Download miniserve (filename format: miniserve-{VERSION}-{TARGET})
    wget -q "https://github.com/svenstaro/miniserve/releases/download/v${LATEST_VERSION}/miniserve-${LATEST_VERSION}-${TARGET}" -O /usr/local/bin/miniserve && \
    chmod +x /usr/local/bin/miniserve

CMD [ "sleep", "infinity" ]
