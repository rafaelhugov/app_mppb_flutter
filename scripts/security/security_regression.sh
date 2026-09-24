#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

failed=0

report() {
  echo "S7 security regression: $*"
  failed=1
}

if git grep -n -E "write\\(key:[[:space:]]*['\"]saved_password['\"]" -- lib; then
  report "senha voltou a ser persistida para biometria"
fi

if ! grep -q 'android:usesCleartextTraffic="false"' android/app/src/main/AndroidManifest.xml; then
  report "AndroidManifest sem usesCleartextTraffic=false"
fi

if git grep -n -E 'token=|queryParameters:[[:space:]]*\{[^}]*["'\'']token["'\'']|Authorization[[:space:]]*:[[:space:]]*["'\'']Token ' -- lib test; then
  report "token voltou a trafegar por query string ou esquema Token legado"
fi

exit "$failed"
