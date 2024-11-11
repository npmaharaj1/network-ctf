# network-ctf
Dependencies:
    - Apache2
    - Containerlab
    - Docker

# Walkthrough
### <b>Step 1:</b> Deployment
Run the following commands:
```bash
git clone https://github.com/npmaharaj1/network-ctf # Clone the ctf repo
cd network-ctf # Enter repo directory
sudo containerlab deploy -t clab_topology.yml # Deploy the containerlab topology
```

### <b>Step 2:</b> Attack
Run the following command to enter the worker504 bash environment (which will be our starting point)
```bash
sudo docker exec -it clab-network-ctf-worker504 bash
```

To start off with, we'll look in our home directory. We as the attackers already have full access to the system (root). Here's the topology of our environmnet from some previous enumeration.
<img src="../assets/readme/topology.png">  
