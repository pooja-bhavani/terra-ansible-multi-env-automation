#!/bin/bash
set -euo pipefail

# Terraform root is one folder up
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# 1) Fetch the SSH private key from Secrets Manager → key.pem
SECRET_NAME=$(terraform -chdir="$ROOT_DIR" output -raw ssh_key_secret_name)
aws secretsmanager get-secret-value \
  --secret-id "$SECRET_NAME" \
  --query SecretString --output text > key.pem
chmod 600 key.pem

# 2) Build the inventory from the EC2 public IPs of the CURRENT workspace
echo "[servers]" > inventory.ini
terraform -chdir="$ROOT_DIR" output -json ec2_public_ips | jq -r '.[]' >> inventory.ini

echo "Inventory built for workspace: $(terraform -chdir="$ROOT_DIR" workspace show)"