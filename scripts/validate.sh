#!/usr/bin/env bash
# Offline checks. No AWS creds. No remote state.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "==> fmt -check"
terraform fmt -check -recursive .

echo "==> validate stacks/dev"
cd "$ROOT/stacks/dev"
terraform init -backend=false -input=false >/dev/null
terraform validate

echo "==> validate modules/jobbser-api"
cd "$ROOT/modules/jobbser-api"
terraform init -backend=false -input=false >/dev/null
terraform validate

echo "ok"
