Pickup notes — Nokia Validated Designs (what I did and how to resume)

Status now
- I created a safe stop script: `scripts/stop_all_labs.sh` (best-effort; does not run automatically). Run it when you want to stop any running labs.
- I created `RUNNING_LABS.md` earlier (contains repository summary and step-by-step deploy instructions).
- I committed and pushed recent changes (including `RUNNING_LABS.md`, `scripts/quickstart_check.sh`, and `scripts/stop_all_labs.sh`) to your fork on GitHub.

How to pick this up later (resume work)
1) Pull latest changes from your fork (if you switch machines):

```bash
git pull origin main
```

2) Check current lab state (locally):

```bash
# list containerlab-managed containers
docker ps --filter "name=clab"

# check containerlab labs
containerlab inspect --all
```

3) If you find running labs you want to stop now, run the safe stop script:

```bash
chmod +x scripts/stop_all_labs.sh
sudo ./scripts/stop_all_labs.sh
```

4) To re-deploy the non-EDA lab later (quick start):

```bash
cd validated-designs/3-stage-evpn-vxlan/3-stage-evpn-vxlan-clab-without-eda
sudo containerlab deploy -t 3-stage-without-eda.clab.yaml
```

5) To re-deploy the EDA-enabled lab later (advanced): follow `RUNNING_LABS.md` instructions. Ensure EDA/k8s is healthy and the iptables bridge rules between kind and containerlab bridge are present.

Notes & tips
- The stop script is best-effort: it will try `containerlab destroy` then stop/remove typical lab containers. It doesn't remove Docker networks or images.
- If you need a full cleanup (networks/images), tell me and I can add a cleanup script — be cautious: it may remove shared networks/images used by other projects.

If you want, I can also create a single `resume.sh` that re-runs the exact deploy commands you used earlier, or open a PR upstream for your changes. Otherwise, you should be all set to pick this up later.
