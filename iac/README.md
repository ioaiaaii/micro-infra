
# Micro-Infra: GKE Cluster Deployment

**Micro-Infra** is a lightweight, cloud-native infrastructure for deploying, managing, and scaling Kubernetes clusters and workloads on **Google Kubernetes Engine (GKE)**. It uses **Terragrunt** and **Terraform** to ensure modular, secure, and reproducible deployments.

---

## Prerequisites

1. **Install Google Cloud SDK**:
   ```bash
   gcloud components install gke-gcloud-auth-plugin
   ```

2. **Enable Required APIs**:
   ```bash
   gcloud services enable container.googleapis.com
   gcloud services enable compute.googleapis.com
   gcloud services enable cloudresourcemanager.googleapis.com
   ```

3. **Authenticate and Set Project**:
   ```bash
   gcloud auth application-default revoke
   gcloud auth login
   gcloud config set project ioaiaaii
   ```

---

## Architecture Overview

The GKE cluster is configured in **VPC-native mode**, enabling private nodes, Alias IPs for pods and services, and enhanced security. Below are the key networking components:

| Component                        | Subnet/Range              | Purpose                          |
|----------------------------------|---------------------------|----------------------------------|
| **Primary Subnet**               | `10.10.0.0/20`            | For GKE Nodes                   |
| **Secondary IP Range (Pods)**    | `192.168.0.0/18`          | Alias IPs assigned to Pods       |
| **Secondary IP Range (Services)**| `192.168.64.0/18`         | Alias IPs assigned to Services   |

### Architecture Diagram

```plaintext
+-------------------------------------------+
| Google Cloud VPC                          |
|                                           |
|   +-------------------------------------+ |
|   | Primary Subnet: 10.10.0.0/20        | |
|   |                                     | |
|   |  +-------------------------------+  | |
|   |  | GKE Node 1 (10.10.0.2)        |  | |
|   |  |  + Pods (192.168.0.0/18)      |  | |
|   |  +-------------------------------+  | |
|   |                                     | |
|   |  +-------------------------------+  | |
|   |  | GKE Node 2 (10.10.0.3)        |  | |
|   |  |  + Pods (192.168.0.0/18)      |  | |
|   |  +-------------------------------+  | |
|   |                                     | |
|   | Secondary IP Ranges:                | |
|   |  - Pods: 192.168.0.0/18             | |
|   |  - Services: 192.168.64.0/18        | |
|   +-------------------------------------+ |
|                                           |
| +---------------------------------------+ |
| | Google Cloud Load Balancer (Public IP)| |
| | External Traffic --> Services --> Pods| |
| +---------------------------------------+ |
+-------------------------------------------+
```

---

## GKE Cluster Features

### General Configuration

| Property                     | Value                   |
|------------------------------|-------------------------|
| **Cluster Name**             | `ioaiaaii`             |
| **Region**                   | `europe-west3`         |
| **Cluster Type**             | Zonal (Single-zone)    |
| **Control Plane CIDR Block** | `172.16.0.0/28`        |
| **Private Endpoint**         | Enabled                |
| **Private Nodes**            | Enabled                |

### Node Pools

| Node Pool Name     | Machine Type | Instance Type | Features             |
|--------------------|--------------|---------------|----------------------|
| `workers-base-pool`| `e2-small`   | Spot          | Cost-efficient, secure boot |
| `infrastructure`   | `e2-small`   | Spot          | Dedicated for infra workloads |

### Networking

- **Alias IPs**:
  - Pods: `192.168.0.0/18`
  - Services: `192.168.64.0/18`
- **Master Authorized Networks**:
  - Worker Nodes: `10.10.0.0/20`
  - Shared Subnet: `10.0.1.0/29`

### Add-ons and Security

- **Disabled Add-ons**:
  - HTTP Load Balancing
  - Horizontal Pod Autoscaling
  - Cloud Monitoring and Logging
- **Security Enhancements**:
  - Shielded Nodes: Enabled
  - Secure Boot: Enabled on all nodes
  - Firewall Rules:
    - Inbound Ports: `8443`, `9443`, `15017`

---

## Managing the GKE Cluster

1. **List Available Clusters**:
   ```bash
   gcloud container clusters list
   ```

2. **Retrieve Cluster Credentials**:
   ```bash
   gcloud container clusters get-credentials ioaiaaii --location europe-west3-a --internal-ip
   ```

3. **Enable Additional APIs**:
   ```bash
   gcloud services enable iap.googleapis.com
   ```

---

## Using a Bastion VM for Secure Access

1. **Start the Bastion VM**:
   ```bash
   gcloud compute instances start "bastion-vm" --zone "europe-west3-a"
   ```

2. **Connect via SSH**:
   ```bash
   gcloud compute ssh --zone "europe-west3-a" "bastion-vm" --tunnel-through-iap --project "micro-infra" -- -L 8888:localhost:8888 -N -q -f
   ```

3. **Export HTTPS Proxy**:
   ```bash
   export HTTPS_PROXY=localhost:8888
   ```

4. **Stop the Bastion VM**:
   ```bash
   gcloud compute instances stop "bastion-vm" --zone "europe-west3-a"
   ```

---

## Additional Notes

- Cloud NAT is essential for private clusters to allow outbound internet traffic from Pods and nodes.

