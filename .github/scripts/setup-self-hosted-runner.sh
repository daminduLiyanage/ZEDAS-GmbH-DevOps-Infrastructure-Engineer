#!/usr/bin/env bash
# Minimal Terraform-only installer for Ubuntu self-hosted runners
# Usage: sudo bash .github/scripts/setup-self-hosted-runner.sh [TERRAFORM_VERSION]

set -euo pipefail

# Default Terraform version (override by passing as first argument or setting TF_VERSION env var)
TF_VERSION=${1:-${TF_VERSION:-"1.5.9"}}

echo "Installing Terraform ${TF_VERSION}"

# Ensure required tools
apt-get update
apt-get install -y --no-install-recommends curl unzip ca-certificates

# Determine architecture
ARCH=$(dpkg --print-architecture || echo "amd64")
if [ "$ARCH" = "amd64" ]; then
  TF_ARCH=linux_amd64
elif [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
  TF_ARCH=linux_arm64
else
  echo "Unsupported architecture: $ARCH" >&2
  exit 1
fi

if command -v terraform >/dev/null 2>&1; then
  echo "Terraform already installed: $(terraform -version | head -n1)"
  exit 0
fi

TMPDIR=$(mktemp -d)
pushd "$TMPDIR"
TF_ZIP="terraform_${TF_VERSION}_${TF_ARCH}.zip"
curl -fsSL -O "https://releases.hashicorp.com/terraform/${TF_VERSION}/${TF_ZIP}"
unzip -o "$TF_ZIP" -d /usr/local/bin/
chmod +x /usr/local/bin/terraform
popd
rm -rf "$TMPDIR"

echo "Installed: $(terraform -version | head -n1)"

exit 0
