#!/usr/bin/env bash
set -e

echo "Quick-start prerequisite checks for Nokia Validated Designs"
echo
# 1: containerlab
printf "1) containerlab: "
if command -v containerlab >/dev/null 2>&1; then
  containerlab version || true
else
  echo "NOT FOUND (install from https://containerlab.dev/install/)"
fi

echo
# 2: docker
printf "2) docker: "
if command -v docker >/dev/null 2>&1; then
  docker --version || true
else
  echo "NOT FOUND (install Docker)"
fi

echo
# 3: docker daemon status
printf "3) docker daemon: "
if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then
    echo "running"
  else
    echo "not accessible (check Docker daemon)"
  fi
else
  echo "skipped"
fi

echo
# 4: resources
printf "4) memory (MB): "
if command -v free >/dev/null 2>&1; then
  free -m | awk '/Mem:/ {printf "%s total, %s available\n", $2, $7}'
else
  echo "free not available"
fi

printf "   cpus: "
if command -v nproc >/dev/null 2>&1; then
  nproc
else
  echo "unknown"
fi

printf "   disk (cwd): "
df -h . | awk 'NR==2 {print $4 " free"}' || true

echo
# 5: docker network bridges
printf "5) docker networks: \n"
docker network ls || echo "docker not available or no networks"

echo
# 6: sudo availability (non-interactive)
printf "6) sudo: "
if command -v sudo >/dev/null 2>&1; then
  if sudo -n true 2>/dev/null; then
    echo "passwordless sudo available"
  else
    echo "sudo requires password (interactive) or restricted"
  fi
else
  echo "sudo not installed"
fi

echo
# 7: sysctl ip_forward
printf "7) net.ipv4.ip_forward: "
sysctl net.ipv4.ip_forward || true

echo
# 8: sample containerlab topology path check
TOP_DIR="/workspaces/nokia-validated-designs/validated-designs/3-stage-evpn-vxlan/3-stage-evpn-vxlan-clab-without-eda"
printf "8) topology file exists: "
if [ -f "$TOP_DIR/3-stage-without-eda.clab.yaml" ]; then
  echo "OK -> $TOP_DIR/3-stage-without-eda.clab.yaml"
else
  echo "MISSING -> expected $TOP_DIR/3-stage-without-eda.clab.yaml"
fi

echo
# Summary guidance
echo "Quick summary:"
echo " - If containerlab and Docker are present and Docker is running, you can deploy the non-EDA lab with:"
echo "     cd $TOP_DIR && sudo containerlab deploy -t 3-stage-without-eda.clab.yaml"
echo " - If sudo requires a password, you must run interactively or configure passwordless sudo beforehand."

echo
exit 0
