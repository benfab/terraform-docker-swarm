# Details for vSphere
variable "vcenter_server"  {default = "<vcenter-endpoint>"}
variable "vcenter_user" {default = "<user>"}
variable "vcenter_password" {default = "<pwd>!"}
variable "vm_resource_pool" {default = "<path to resource pool>"}
variable "vm_folder" {default = "<folder-name>"}
variable "vcenter_dc" {default = "<datacenter-name>"}
variable "vcenter_cluster" {default = "<cluster-name>}
variable "dns_servers" {default = "10.79.255.100,10.79.255.200"}
variable "vm_template" {default = "<template-name>"}
variable "vm_datastore" {default = "<datastore-name"}


# Details for the Swarm manager nodes
variable "manager_count" {default = 3}
variable "manager_cpu" {default = 2}
variable "manager_mem" {default = 4096}
#variable "manager_gateway" {default = "10.32.130.1"}
#variable "manager_netmask" {default = "24"}


# Details Swarm workers
variable "worker_count" {default = 1}
variable "worker_cpu" {default = 2}
variable "worker_mem" {default = 4096}
#variable "worker_gateway" {default = "10.32.130.1"}
#variable "worker_netmask" {default = "24"}

# Networks
variable "ip_range" {default = "10.32.130.21"}
variable "vm_network" {default = "<network-name>"}

# Private key
variable "private_key" {default = "/root/.ssh/id_rsa.pem"}

# Logo
variable "logo" {default = "https://www.docker.com/sites/default/files/vertical_large.png"}
