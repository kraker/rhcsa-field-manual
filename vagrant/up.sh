#!/usr/bin/env bash
# Bring up the dev VM. Sources Red Hat credentials so the
# vagrant-registration plugin can register the box with RHSM.
set -euo pipefail

cd "$(dirname "$0")"

if [ ! -f ".rhel-credentials" ]; then
    echo "ERROR: .rhel-credentials not found"
    echo "  cp .rhel-credentials.template .rhel-credentials"
    echo "  edit .rhel-credentials with your Red Hat Developer credentials"
    exit 1
fi

# shellcheck source=/dev/null
source .rhel-credentials

if [ -z "${RHSM_USERNAME:-}" ] || [ -z "${RHSM_PASSWORD:-}" ]; then
    echo "ERROR: RHSM_USERNAME / RHSM_PASSWORD not set in .rhel-credentials"
    exit 1
fi

vagrant up

cat <<'EOF'

VM is up. Useful next steps:

  vagrant ssh                          # log in
  vagrant ssh-config >> ~/.ssh/config  # so VS Code Remote SSH can connect
  vagrant halt                         # stop the VM
  vagrant destroy                      # remove the VM

EOF
