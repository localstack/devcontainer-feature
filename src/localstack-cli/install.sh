#!/bin/bash

set -e

LS_VERSION=${VERSION:-"latest"}
INSTALL_USING_PYTHON=${INSTALLUSINGPYTHON:-false}
test "${AWSLOCAL:-false}" = true && LOCAL_AWS=awscli-local
test "${CDKLOCAL:-false}" = true && LOCAL_CDK=aws-cdk-local
test "${PULUMILOCAL:-false}" = true && LOCAL_PULUMI=pulumi-local
test "${TFLOCAL:-false}" = true && LOCAL_TF="terraform-local"
test "${SAMLOCAL:-false}" = true && LOCAL_SAM="aws-sam-cli-local"
PREFIX=LOCAL_

eval 'TOOLS=(${!'"$PREFIX"'@})'

# Clean up
rm -rf /var/lib/apt/lists/*

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
. /etc/os-release
# Get an adjusted ID independent of distro variants
MAJOR_VERSION_ID=$(echo ${VERSION_ID} | cut -d . -f 1)
if [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]; then
    ADJUSTED_ID="debian"
else
    echo "Linux distro ${ID} not supported."
    exit 1
fi

# Setup INSTALL_CMD & PKG_MGR_CMD
if type apt-get > /dev/null 2>&1; then
    PKG_MGR_CMD=apt-get
    INSTALL_CMD="${PKG_MGR_CMD} -y install --no-install-recommends"
elif type microdnf > /dev/null 2>&1; then
    PKG_MGR_CMD=microdnf
    INSTALL_CMD="${PKG_MGR_CMD} ${INSTALL_CMD_ADDL_REPOS} -y install --refresh --best --nodocs --noplugins --setopt=install_weak_deps=0"
elif type dnf > /dev/null 2>&1; then
    PKG_MGR_CMD=dnf
    INSTALL_CMD="${PKG_MGR_CMD} ${INSTALL_CMD_ADDL_REPOS} -y install --refresh --best --nodocs --noplugins --setopt=install_weak_deps=0"
else
    PKG_MGR_CMD=yum
    INSTALL_CMD="${PKG_MGR_CMD} ${INSTALL_CMD_ADDL_REPOS} -y install --noplugins --setopt=install_weak_deps=0"
fi

# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

# General requirements
REQUIRED_PKGS=""
case ${ADJUSTED_ID} in
    debian)
        REQUIRED_PKGS="${REQUIRED_PKGS} \
            gcc \
            python3-dev \
            python3-venv"
        ;;
esac

pkg_mgr_update() {
    case ${ADJUSTED_ID} in
        debian)
            if [ "$(find /var/lib/apt/lists -iname '*' | wc -l)" = "1" ]; then
                echo "Running apt-get update..."
                ${PKG_MGR_CMD} update -y
            fi
            ;;
    esac
}

add_backports() {
    case ${ID} in
        debian)
            echo "deb http://ftp.debian.org/debian ${VERSION_CODENAME}-backports main" |
            tee /etc/apt/sources.list.d/backports.list
            ;;
        ubuntu)
            echo "deb http://archive.ubuntu.com/ubuntu ${VERSION_CODENAME}-backports main" |
            tee /etc/apt/sources.list.d/backports.list
            ;;
    esac
}

# Checks if packages are installed and installs them if not
check_packages() {
    case ${ADJUSTED_ID} in
        debian)
            if ! dpkg -s "$@" > /dev/null 2>&1; then
                add_backports
                pkg_mgr_update
                ${INSTALL_CMD} "$@"
            fi
            ;;
    esac
}

install_using_pip_strategy() {
    local ver=""
    case ${LS_VERSION} in
        "")
        ;&
        none)
        ;&
        lts)
        ;&
        latest)
        ;&
        stable)
            ver=""
        ;;
        *)
            ver="==${LS_VERSION}"
        ;;
    esac

    if [ "${INSTALL_USING_PYTHON}" = "true" ]; then
        install_with_complete_python_installation "${ver}" || install_with_pipx "${ver}" || return 1
    else
        install_with_pipx "${ver}" || install_with_complete_python_installation "${ver}" || return 1
    fi
}

install_with_pipx() {
    echo "(*) Attempting to install globally with pipx..."
    local ver="$1"
    export 
    local 

    if ! type pipx > /dev/null 2>&1; then
        echo "(*) Installing pipx..."
        check_packages pipx ${REQUIRED_PKGS}
        pipx ensurepath # Ensures PIPX_BIN_DIR is on the PATH
    fi

    PIPX_HOME="/usr/local/pipx" \
    PIPX_BIN_DIR=/usr/local/bin \
    pipx install localstack${ver} --include-deps

    echo "(*) Finished installing globally with pipx."
}

install_with_complete_python_installation() {
    local ver="$1"
    if ! dpkg -s ${REQUIRED_PKGS} > /dev/null 2>&1; then
        check_packages ${REQUIRED_PKGS}
    fi
    export PIPX_HOME=/usr/local/pipx
    mkdir -p ${PIPX_HOME}
    export PIPX_BIN_DIR=/usr/local/bin
    export PYTHONUSERBASE=/tmp/pip-tmp
    export PIP_CACHE_DIR=/tmp/pip-tmp/cache
    pipx_bin=pipx
    if ! type pipx > /dev/null 2>&1; then
        pip3 install --disable-pip-version-check --no-cache-dir --user pipx
        pipx_bin=/tmp/pip-tmp/bin/pipx
    fi

    set +e
        ${pipx_bin} install --pip-args '--no-cache-dir --force-reinstall --include-deps' -f localstack${ver}

        # Fail gracefully
        if [ "$?" != 0 ]; then
            echo "Could not install localstack${ver} via pip3"
            rm -rf /tmp/pip-tmp
            return 1
        fi
    set -e
}

install_tool() {
    local tool=$(eval echo "\$$1")
    case $tool in
        aws-cdk-local)
            npm install -g $tool aws-cdk
        ;;
        *)
            PIPX_HOME="/usr/local/pipx" \
            PIPX_BIN_DIR=/usr/local/bin \
            pipx install $tool
        ;;
    esac
}

install_tools() {
    for tool in ${TOOLS[@]}; do
        install_tool $tool
    done
}

add_backports

install_using_pip_strategy

install_tools

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"