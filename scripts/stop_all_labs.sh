#!/usr/bin/env bash
set -euo pipefail

# stop_all_labs.sh
# Best-effort script to stop containerlab labs and related containers created by these designs.
# Run this script with sufficient privileges (sudo may be required to stop containers/networks).

echo "Starting stop_all_labs.sh (best-effort)"

if command -v containerlab >/dev/null 2>&1; then
  echo "Attempting graceful containerlab destroy --all"
  containerlab destroy --all 2>/dev/null || containerlab destroy -a 2>/dev/null || true
else
  echo "containerlab not found; skipping containerlab destroy"
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "docker not found; nothing to stop"
  exit 0
fi

# Stop & remove containers whose name contains 'clab'
CLAB_CONTAINERS=$(docker ps --filter "name=clab" -q || true)
if [ -n "$CLAB_CONTAINERS" ]; then
  echo "Stopping containerlab containers..."
  for c in $CLAB_CONTAINERS; do
    docker stop "$c" || true
  done
  echo "Removing containerlab containers..."
  for c in $CLAB_CONTAINERS; do
    docker rm -f "$c" || true
  done
else
  echo "No containerlab containers found."
fi

# Stop containers by ancestor images (common lab images)
for IMG in "ghcr.io/srl-labs/network-multitool" "ghcr.io/nokia/srlinux"; do
  CONTAINERS=$(docker ps --filter "ancestor=$IMG" -q || true)
  if [ -n "$CONTAINERS" ]; then
    echo "Stopping containers from image $IMG"
    for c in $CONTAINERS; do
      docker stop "$c" || true
      docker rm -f "$c" || true
    done
  fi
done

echo "stop_all_labs.sh completed (best-effort)."
