#!/usr/bin/env bash
# Installs lstk, the LocalStack CLI, from its GitHub release archive.
set -euo pipefail

LSTK_VERSION="${VERSION:-latest}"
INSTALL_PULUMILOCAL="${PULUMILOCAL:-false}"
LSTK_REPO="https://github.com/localstack/lstk"
INSTALL_DIR="/usr/local/lib/lstk"
BIN_LINK="/usr/local/bin/lstk"

log() { echo "(*) $*"; }
fail() { echo "(!) $*" >&2; exit 1; }

if [ "$(id -u)" -ne 0 ]; then
    fail 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
fi

# curl, tar, gzip and CA certificates are the only runtime needs.
# lstk itself is a static binary, so no Python or Node.js is required.
install_prerequisites() {
    local missing=()
    command -v curl > /dev/null 2>&1 || missing+=(curl)
    command -v tar > /dev/null 2>&1 || missing+=(tar)
    command -v gzip > /dev/null 2>&1 || missing+=(gzip)
    [ -f /etc/ssl/certs/ca-certificates.crt ] || [ -f /etc/pki/tls/certs/ca-bundle.crt ] || missing+=(ca-certificates)
    [ "${#missing[@]}" -eq 0 ] && return 0

    log "Installing prerequisites: ${missing[*]}"
    if command -v apt-get > /dev/null 2>&1; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -y
        apt-get install -y --no-install-recommends "${missing[@]}"
        rm -rf /var/lib/apt/lists/*
    elif command -v apk > /dev/null 2>&1; then
        apk add --no-cache "${missing[@]}"
    elif command -v microdnf > /dev/null 2>&1; then
        microdnf install -y "${missing[@]}"
        microdnf clean all
    elif command -v dnf > /dev/null 2>&1; then
        dnf install -y "${missing[@]}"
        dnf clean all
    elif command -v yum > /dev/null 2>&1; then
        yum install -y "${missing[@]}"
        yum clean all
    else
        fail "Missing ${missing[*]} and no supported package manager (apt-get, apk, dnf, microdnf, yum) found."
    fi
}

detect_arch() {
    case "$(uname -m)" in
        x86_64 | amd64) echo "amd64" ;;
        aarch64 | arm64) echo "arm64" ;;
        *) fail "Unsupported architecture $(uname -m). lstk ships linux/amd64 and linux/arm64 builds." ;;
    esac
}

# Resolves "latest" through the release redirect, which avoids the
# GitHub API and its rate limit for anonymous builds.
resolve_version() {
    local requested="$1"
    case "${requested}" in
        "" | latest)
            local url
            url=$(curl -fsSLI -o /dev/null -w '%{url_effective}' "${LSTK_REPO}/releases/latest") \
                || fail "Could not resolve the latest lstk release from ${LSTK_REPO}/releases/latest"
            requested="${url##*/}"
            ;;
    esac
    requested="${requested#v}"
    [[ "${requested}" =~ ^[0-9]+\.[0-9]+\.[0-9]+([-.][0-9A-Za-z.-]+)?$ ]] \
        || fail "Invalid lstk version '${requested}'. Use 'latest' or a release such as '1.5.0'."
    echo "${requested}"
}

sha256_check() {
    if command -v sha256sum > /dev/null 2>&1; then
        sha256sum -c -
    else
        shasum -a 256 -c -
    fi
}

install_completions() {
    local src="$1/completions"
    [ -d "${src}" ] || return 0
    install -D -m 0644 "${src}/lstk.bash" /usr/share/bash-completion/completions/lstk
    install -D -m 0644 "${src}/lstk.zsh" /usr/local/share/zsh/site-functions/_lstk
    install -D -m 0644 "${src}/lstk.fish" /usr/share/fish/vendor_completions.d/lstk.fish
}

install_manpages() {
    local src="$1/manpages"
    [ -d "${src}" ] || return 0
    mkdir -p /usr/local/share/man/man1
    cp "${src}"/*.1 /usr/local/share/man/man1/
}

# pulumi-local is the one LocalStack wrapper without an lstk equivalent.
# It is a Python package, so pipx is only pulled in when it is requested.
install_pulumilocal() {
    if ! command -v pipx > /dev/null 2>&1; then
        log "Installing pipx"
        if command -v apt-get > /dev/null 2>&1; then
            export DEBIAN_FRONTEND=noninteractive
            apt-get update -y
            apt-get install -y --no-install-recommends pipx
            rm -rf /var/lib/apt/lists/*
        elif command -v apk > /dev/null 2>&1; then
            apk add --no-cache pipx
        elif command -v pip3 > /dev/null 2>&1; then
            pip3 install --no-cache-dir pipx
        else
            fail "pulumilocal needs pipx. Add the Python Feature (ghcr.io/devcontainers/features/python) or install pipx in the base image."
        fi
    fi
    log "Installing pulumi-local"
    PIPX_HOME=/usr/local/pipx PIPX_BIN_DIR=/usr/local/bin pipx install --force pulumi-local
    command -v pulumi > /dev/null 2>&1 \
        || echo "(!) pulumi is not on PATH. Add ghcr.io/devcontainers-extra/features/pulumi:1 to use pulumilocal."
}

install_prerequisites

ARCH="$(detect_arch)"
VERSION_NUMBER="$(resolve_version "${LSTK_VERSION}")"
ARCHIVE="lstk_${VERSION_NUMBER}_linux_${ARCH}.tar.gz"
BASE_URL="${LSTK_REPO}/releases/download/v${VERSION_NUMBER}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

log "Downloading lstk ${VERSION_NUMBER} (linux/${ARCH})"
curl -fsSL --retry 3 -o "${TMP_DIR}/${ARCHIVE}" "${BASE_URL}/${ARCHIVE}" \
    || fail "Could not download ${BASE_URL}/${ARCHIVE}. Check that lstk ${VERSION_NUMBER} exists."
curl -fsSL --retry 3 -o "${TMP_DIR}/checksums.txt" "${BASE_URL}/checksums.txt" \
    || fail "Could not download ${BASE_URL}/checksums.txt"

log "Verifying checksum"
(cd "${TMP_DIR}" && grep " ${ARCHIVE}\$" checksums.txt | sha256_check) \
    || fail "Checksum verification failed for ${ARCHIVE}"

# The archive carries the lstk binary plus the bundled extensions
# (e.g. `lstk doctor`). lstk finds them next to its resolved executable,
# so the archive is unpacked as a whole and only the binary is linked.
rm -rf "${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}"
tar -xzf "${TMP_DIR}/${ARCHIVE}" -C "${INSTALL_DIR}"
ln -sf "${INSTALL_DIR}/lstk" "${BIN_LINK}"

install_completions "${INSTALL_DIR}"
install_manpages "${INSTALL_DIR}"

# Let the container user run `lstk update` without sudo.
if [ -n "${_REMOTE_USER:-}" ] && [ "${_REMOTE_USER}" != "root" ] && id -u "${_REMOTE_USER}" > /dev/null 2>&1; then
    chown -R "${_REMOTE_USER}" "${INSTALL_DIR}"
fi

if [ "${INSTALL_PULUMILOCAL}" = "true" ]; then
    install_pulumilocal
fi

"${BIN_LINK}" --version
log "Done."
