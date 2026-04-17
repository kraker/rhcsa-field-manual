#!/usr/bin/env bash
# Install the toolchain needed to build the book on the VM:
#   - Quarto (latest GitHub release) for rendering
#   - R (with renv; project deps pinned in renv.lock) for the knitr engine
#   - uv (latest GitHub release) for Python tooling
#   - git for working with the repo from inside the VM
#
# RHEL-specific repo enablement: subscription-manager attaches CRB
# (CodeReady Builder, where R lives) and we install EPEL from Fedora's
# upstream URL since RHEL doesn't ship epel-release.
set -euo pipefail

echo "==> Enabling CRB (CodeReady Builder; R lives there)"
subscription-manager repos --enable codeready-builder-for-rhel-10-x86_64-rpms

echo "==> Installing EPEL"
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm

echo "==> Installing base packages"
# cmake is needed to build the R `fs` package (transitive dep of
# rmarkdown via bslib → sass → fs). `fs` bundles libuv and always
# statically links it via cmake, regardless of system libuv.
dnf install -y git curl tar R cmake

echo "==> Installing latest Quarto"
QUARTO_VERSION="$(curl -fsSL https://api.github.com/repos/quarto-dev/quarto-cli/releases/latest \
  | sed -n 's/.*"tag_name": "v\([^"]*\)".*/\1/p')"
# Quarto's RPM assets are named with the kernel arch (x86_64 / aarch64),
# not Debian-style (amd64 / arm64) like the .deb assets.
QUARTO_RPM="quarto-${QUARTO_VERSION}-linux-$(uname -m).rpm"
curl -fsSL -o "/tmp/${QUARTO_RPM}" \
  "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/${QUARTO_RPM}"
dnf install -y "/tmp/${QUARTO_RPM}"
rm -f "/tmp/${QUARTO_RPM}"

echo "==> Installing renv"
# R project deps are pinned in renv.lock at the repo root (symmetric
# with pyproject.toml/uv.lock for Python). provision.sh only installs
# renv itself; users run `renv::restore()` after cloning to populate
# the project library from the lockfile.
R -e "install.packages('renv', repos='https://cloud.r-project.org')"

echo "==> Installing latest uv"
UV_VERSION="$(curl -fsSL https://api.github.com/repos/astral-sh/uv/releases/latest \
  | sed -n 's/.*"tag_name": "\([^"]*\)".*/\1/p')"
UV_TRIPLE="$(uname -m)-unknown-linux-gnu"
UV_TARBALL="uv-${UV_TRIPLE}.tar.gz"
curl -fsSL -o "/tmp/${UV_TARBALL}" \
  "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/${UV_TARBALL}"
tar -xzf "/tmp/${UV_TARBALL}" -C /tmp
install -m 0755 "/tmp/uv-${UV_TRIPLE}/uv"  /usr/local/bin/uv
install -m 0755 "/tmp/uv-${UV_TRIPLE}/uvx" /usr/local/bin/uvx
rm -rf "/tmp/${UV_TARBALL}" "/tmp/uv-${UV_TRIPLE}"

# `quarto` and `uv` are in /usr/local/bin, which isn't yet in this
# shell's PATH cache, so call them by absolute path for the banner.
echo "==> Done. Quarto $(/usr/local/bin/quarto --version), R $(R --version | head -1 | awk '{print $3}'), uv $(/usr/local/bin/uv --version | awk '{print $2}')"
