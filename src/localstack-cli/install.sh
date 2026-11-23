#!/bin/bash

set -e

LSTK_VERSION=${VERSION:-"latest"}
LSTK_REPO="https://github.com/localstack/lstk"
LSTK_INSTALL_DIR=/usr/local/lib/lstk

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
. /etc/os-release
if [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]; then
    ADJUSTED_ID="debian"
else
    echo "Linux distro ${ID} not supported."
    exit 1
fi

# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

# Checks if packages are installed and installs them if not
check_packages() {
    case ${ADJUSTED_ID} in
        debian)
            if ! dpkg -s "$@" > /dev/null 2>&1; then
                if [ "$(find /var/lib/apt/lists/* 2>/dev/null | wc -l)" = "0" ]; then
                    echo "Running apt-get update..."
                    apt-get update -y
                fi
                apt-get -y install --no-install-recommends "$@"
            fi
            ;;
    esac
}

# Resolves the lstk release version ("latest" -> newest release tag, "v1.2.3" -> "1.2.3")
resolve_lstk_version() {
    case ${LSTK_VERSION} in
        ""|latest)
            local url
            url=$(curl -fsSLI --retry 3 -o /dev/null -w '%{url_effective}' "${LSTK_REPO}/releases/latest") || return 1
            echo "${url##*/tag/v}"
            ;;
        *)
            echo "${LSTK_VERSION#v}"
            ;;
    esac
}

install_lstk() {
    echo "(*) Installing lstk..."
    check_packages curl ca-certificates tar

    local arch
    case "$(uname -m)" in
        x86_64|amd64) arch=amd64 ;;
        aarch64|arm64) arch=arm64 ;;
        *)
            echo "Architecture $(uname -m) is not supported by lstk."
            return 1
            ;;
    esac

    local version
    version=$(resolve_lstk_version) || version=""
    if ! [[ "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
        echo "Could not determine lstk version to install (version=${LSTK_VERSION})."
        return 1
    fi

    local archive="lstk_${version}_linux_${arch}.tar.gz"
    local base_url="${LSTK_REPO}/releases/download/v${version}"
    local tmp_dir
    tmp_dir=$(mktemp -d)

    echo "(*) Downloading ${archive}..."
    curl -fsSL --retry 3 -o "${tmp_dir}/${archive}" "${base_url}/${archive}"
    curl -fsSL --retry 3 -o "${tmp_dir}/checksums.txt" "${base_url}/checksums.txt"
    (cd "${tmp_dir}" && grep " ${archive}\$" checksums.txt | sha256sum -c -)

    # Keep the binary next to its bundled extensions and link it onto the PATH
    rm -rf "${LSTK_INSTALL_DIR}"
    mkdir -p "${LSTK_INSTALL_DIR}"
    tar -xzf "${tmp_dir}/${archive}" -C "${LSTK_INSTALL_DIR}"
    ln -sf "${LSTK_INSTALL_DIR}/lstk" /usr/local/bin/lstk

    if [ -d /usr/share/bash-completion/completions ]; then
        cp "${LSTK_INSTALL_DIR}/completions/lstk.bash" /usr/share/bash-completion/completions/lstk
    fi
    if [ -d /usr/local/share/zsh/site-functions ] || type zsh > /dev/null 2>&1; then
        mkdir -p /usr/local/share/zsh/site-functions
        cp "${LSTK_INSTALL_DIR}/completions/lstk.zsh" /usr/local/share/zsh/site-functions/_lstk
    fi

    rm -rf "${tmp_dir}"
    echo "(*) Finished installing lstk ${version}."
}

install_lstk

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
