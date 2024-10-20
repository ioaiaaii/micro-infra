
wiiiipppppppp

####
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com

#cloudresourcemanager.googleapis.com

if changed project
gcloud auth application-default revoke
gcloud auth login
gcloud config set project ioaiaaii

select europe-west3


### vpc
+-------------------------------------------+
|           Google Cloud VPC                |
|                                           |
|  +-------------------------------------+  |
|  |  Primary Subnet: 10.10.0.0/20       |  |
|  |  (Used for GKE Nodes)               |  |
|  |                                     |  |
|  |  +-------------------------------+  |  |
|  |  | GKE Node 1 (10.10.0.2)         |  |  |
|  |  |  + Pods (192.168.0.0/18)       |  |  |
|  |  +-------------------------------+  |  |
|  |                                     |  |
|  |  +-------------------------------+  |  |
|  |  | GKE Node 2 (10.10.0.3)         |  |  |
|  |  |  + Pods (192.168.0.0/18)       |  |  |
|  |  +-------------------------------+  |  |
|  |                                     |  |
|  |  Secondary IP Range (Pods):        |  |
|  |    192.168.0.0/18                  |  |
|  |  Secondary IP Range (Services):    |  |
|  |    192.168.64.0/18                 |  |
|  +-------------------------------------+  |
|                                           |
|   Google Cloud Load Balancer (Public IP)  |
|   External traffic --> Services --> Pods  |
+-------------------------------------------+

In GKE, VPC-native mode integrates clusters with Google Cloud VPC using Alias IPs for Pods and Services.

Key Concepts:
Primary Subnet: For GKE nodes (VMs).
Secondary IP Ranges: For Pods and Services.
CNI: Manages Pod IPs for direct communication within the VPC.
Private Clusters: Use Cloud NAT for internet access, while nodes and control plane use private IPs.
NAT in GKE
Scenario	NAT Involved?
Pod-to-Pod Communication	No
Pod-to-External Communication	Yes
Service-to-External Communication	Yes
Node-to-External Communication	Yes
Control Plane Access (Private)	No
Cloud NAT is used in private clusters for outbound internet access.




  gcloud components install gke-gcloud-auth-plugin

➜  europe-west-3 gcloud container clusters list  

NAME      LOCATION        MASTER_VERSION      MASTER_IP   MACHINE_TYPE  NODE_VERSION        NUM_NODES  STATUS
ioaiaaii  europe-west3-a  1.29.8-gke.1211000  172.16.0.2  e2-small      1.29.8-gke.1211000  1          RUNNING




gcloud container clusters get-credentials ioaiaaii --location europe-west3-a --internal-ip



gcloud billing accounts list
gcloud services enable iap.googleapis.com

gcloud compute instances start "bastion-vm" --zone "europe-west3-a"
gcloud compute ssh --zone "europe-west3-a" "bastion-vm" --tunnel-through-iap --project "micro-infra" --  -L 8888:localhost:8888 -N -q -f

export HTTPS_PROXY=localhost:8888





gcloud compute instances stop "bastion-vm" --zone "europe-west3-a"
