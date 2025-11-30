# Nokia Validated Designs — Run Instructions

This file summarizes the repository and provides step-by-step, copy-pasteable instructions to run the labs found in this repository.

---

## Purpose

Nokia Validated Designs (NVDs) provides deployable virtual network designs using Containerlab and Nokia SR Linux images. The repository contains both "validated designs" (official NVDs) and "reference designs" (community reference labs). Many designs provide Containerlab topology files (`*.clab.yaml`), helper scripts, and — for some designs — EDA manifests to orchestrate the fabric with Nokia EDA.

---

## Key locations

- Top-level `README.md` — project overview and links.
- `example.clab.yml` — minimal Containerlab example.
- `reference-designs/` — reference/topology examples and scripts. Example: `reference-designs/3-stage-evpn-vxlan-ebgp-underlay-ibgp-overlay/`.
- `validated-designs/` — official NVDs. Example: `validated-designs/3-stage-evpn-vxlan/`.
  - Non-EDA topology: `validated-designs/3-stage-evpn-vxlan/3-stage-evpn-vxlan-clab-without-eda/3-stage-without-eda.clab.yaml`
  - EDA-enabled topology + manifests: `validated-designs/3-stage-evpn-vxlan/3-stage-evpn-vxlan-clab-with-eda/` (includes `3-stage-with-eda.clab.yaml`, `deploy-3-stage-nvd.sh`, `destroy-3-stage-nvd.sh`, and multiple EDA manifest YAML files).

---

## Prerequisites (both paths)

- Linux host with Docker and Containerlab installed (Containerlab >= 0.61.0 recommended).
- Sufficient resources: recommended >= 4 vCPU, 16 GB RAM.
- Network access to pull images from `ghcr.io`.
- `sudo` access to run `containerlab deploy/destroy` and to add iptables rules when needed.

Quick checks:
```bash
authorized: containerlab version
docker --version
docker network ls
```

---

## Option A — Quick: Non-EDA topology (recommended first)

This instantiates the 3-stage EVPN VXLAN NVD digital twin without EDA orchestration.

1) Clone the repository (skip if already present):
```bash
git clone https://github.com/nokia/nokia-validated-designs.git
cd nokia-validated-designs/validated-designs/3-stage-evpn-vxlan/3-stage-evpn-vxlan-clab-without-eda
```

2) Inspect the topology (optional):
```bash
less 3-stage-without-eda.clab.yaml
```
Note: management network is `eda_mgmt` with IPv4 subnet `172.21.21.0/24` and node mgmt IPs are configured in the YAML.

3) Deploy the topology:
```bash
sudo containerlab deploy -t 3-stage-without-eda.clab.yaml
```

4) Confirm the lab is up:
```bash
containerlab inspect --name 3-stage-nvd-without-eda
docker ps --filter "name=clab"
```

5) Access nodes
- SR Linux login: `admin` / `NokiaSrl1!`
- Helper host login: `user` / `multit00l`

Example SSH (IP defined in YAML):
```bash
ssh admin@172.21.21.11
# password: NokiaSrl1!
```
If SSH is not responding, use `docker exec` to open a shell inside the container (get container name from `containerlab inspect`).

6) Tear down the lab:
```bash
sudo containerlab destroy -t 3-stage-without-eda.clab.yaml
```

Troubleshooting (non-EDA):
- If images fail to pull: `docker pull ghcr.io/nokia/srlinux:24.10.2` (or the image tag in the YAML).
- If permission issues appear, run with `sudo`.
- Check container logs: `docker logs <container-name>`.

---

## Option B — Advanced: EDA-orchestrated topology

This path requires a working Nokia EDA (installed in a Kubernetes cluster, recommended via `kind`) and a valid EDA license. The Containerlab topology and EDA should be reachable to each other — follow the notes below.

1) Prerequisites (EDA):
- Kubernetes cluster with EDA installed (kind recommended).
- EDA SIMULATE flag must be `false` to allow external node onboarding.
- EDA license installed: `kubectl describe license -A`.
- `kubectl` configured for the EDA cluster.

2) Clone repo and change folder:
```bash
git clone https://github.com/nokia/nokia-validated-designs.git
cd nokia-validated-designs/validated-designs/3-stage-evpn-vxlan/3-stage-evpn-vxlan-clab-with-eda
```

3) Deploy the Containerlab topology:
```bash
sudo containerlab deploy -t 3-stage-with-eda.clab.yaml
```

4) Ensure EDA–Containerlab bridge connectivity
- Identify EDA kind bridge (example `172.19.0.0/16`) and containerlab bridge (`172.21.21.0/24`). Add iptables forwarding rules:
```bash
sudo iptables -I FORWARD -s 172.21.21.0/24 -d 172.19.0.0/16 -j ACCEPT
sudo iptables -I FORWARD -s 172.19.0.0/16 -d 172.21.21.0/24 -j ACCEPT
```
You can find the bridge networks via `docker network ls` and `ifconfig br-<id>`.

5) Deploy EDA manifests for the lab (script provided):
```bash
chmod +x deploy-3-stage-nvd.sh
./deploy-3-stage-nvd.sh
```
The script runs `kubectl apply` on the provided YAML manifests and waits for nodes/resources to sync.

6) Validate EDA onboarding and fabric:
```bash
kubectl get toponode -A
kubectl get bridgedomain -A
kubectl get pods -n eda
kubectl -n eda logs <pod-name>
```

7) Destroying EDA resources and lab:
```bash
chmod +x destroy-3-stage-nvd.sh
./destroy-3-stage-nvd.sh
sudo containerlab destroy -t 3-stage-with-eda.clab.yaml
```

EDA troubleshooting tips:
- If nodes are not in the desired state, ensure the EDA `bsvr` and node agents are ready and that iptables rules permit connectivity.
- Check `kubectl logs` for bootstrap server and node agent pods.
- Verify license with `kubectl describe license -A`.

---

## Helpful commands (summary)

```bash
# Containerlab
containerlab deploy -t <topology>.clab.yaml
containerlab destroy -t <topology>.clab.yaml
containerlab inspect --name <labname>

# Docker
docker ps --filter "name=clab"
docker logs <container-name>

# Kubernetes / EDA
kubectl get pods -n <eda-namespace>
kubectl -n <eda-namespace> logs <pod-name>
```

---

## Files referenced (examples)
- `validated-designs/3-stage-evpn-vxlan/3-stage-evpn-vxlan-clab-without-eda/3-stage-without-eda.clab.yaml`
- `validated-designs/3-stage-evpn-vxlan/3-stage-evpn-vxlan-clab-with-eda/3-stage-with-eda.clab.yaml`
- `validated-designs/3-stage-evpn-vxlan/3-stage-evpn-vxlan-clab-with-eda/deploy-3-stage-nvd.sh`
- `validated-designs/3-stage-evpn-vxlan/3-stage-evpn-vxlan-clab-with-eda/destroy-3-stage-nvd.sh`

---

## Next steps I can help with
- Run one of the deployment commands from within this devcontainer (I can execute `containerlab deploy` if you want and the environment supports it).
- Add a smaller quick-start script to automate common checks before deploy.
- Deep-dive into any specific file (topology YAML, configlets, or `node-isolation.py`).

If you want me to run the lab now, tell me which option (A or B) and confirm I should execute the necessary `containerlab` and/or `deploy-3-stage-nvd.sh` commands from this environment.
