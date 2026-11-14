#!/usr/bin/env bash

echo "=========================================="
echo "   DevOps Workstation Verification"
echo "=========================================="
echo "User: $(whoami) | Host: $(hostname) | Date: $(date)"
echo ""

TOOLS=(git docker kubectl minikube helm aws az node jq terraform ansible)
MISSING=0

echo "--- 1. Checking Installed Tools ---"
for tool in "${TOOLS[@]}"; do
  if command -v "$tool" >/dev/null 2>&1; then
    echo "[OK]      $tool -> $(command -v "$tool")"
  else
    echo "[MISSING] $tool is NOT installed or not in PATH"
    MISSING=$((MISSING + 1))
  fi
done

echo ""
echo "--- 2. Checking Permissions & Security ---"
if groups | grep -qw "docker"; then
  echo "[OK]      User '$(whoami)' is in the 'docker' group (non-root access enabled)"
else
  echo "[WARN]    User '$(whoami)' is NOT in the 'docker' group"
fi

if docker info >/dev/null 2>&1; then
  echo "[OK]      Docker daemon is running and accessible without sudo"
else
  echo "[WARN]    Docker daemon is unreachable (ensure Docker Desktop is running)"
fi

for dir in "$HOME/.ssh" "$HOME/.kube"; do
  if [ -d "$dir" ]; then
    PERMS=$(stat -c "%a" "$dir")
    echo "[INFO]    $dir exists with permissions: $PERMS"
  else
    echo "[INFO]    $dir not created yet"
  fi
done

echo ""
echo "=========================================="
if [ "$MISSING" -eq 0 ]; then
  echo "SUCCESS: All ${#TOOLS[@]} DevOps tools verified!"
else
  echo "ALERT: $MISSING tool(s) missing. Check output above."
fi
echo "=========================================="
