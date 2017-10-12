# Configure the VMware vSphere Provider
provider "vsphere" {
  user           = "${var.vcenter_user}"
  password       = "${var.vcenter_password}"
  vsphere_server = "${var.vcenter_server}"
  # Allow self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "vic" {}

# Create a folder
resource "vsphere_folder" "swarm" {
  datacenter_id = "${data.vsphere_datacenter.vic.id}"
  type = "vm"
  path = "Swarm"
}

# Swarm managers
resource "vsphere_virtual_machine" "swarm-manager" {
  name   = "swarm-manager-${format("%02d", count.index+1)}"
  count = "${var.manager_count}"
  datacenter = "${var.vcenter_dc}"
  cluster = "${var.vcenter_cluster}"
  resource_pool = "${var.vm_resource_pool}"
  folder = "${vsphere_folder.swarm.path}"
  vcpu   = "${var.manager_cpu}"
  memory = "${var.manager_mem}"
  dns_servers = [ "10.79.255.100" ]
  
  connection {
        user = "root"
        private_key = "${file("${var.private_key}")}"
    }

  network_interface {
    label = "${var.vm_network}"
    ipv4_address = "${var.ip_range}${format(count.index+2)}"
    ipv4_prefix_length = "24"
    ipv4_gateway = "10.32.130.1"
  }

  disk {
    template = "${var.vm_template}"
    datastore = "${var.vm_datastore}"
    type = "thin"
  }
 provisioner "remote-exec" {
      inline = [
        " if [ ${count.index} -eq 0 ]; then sudo docker swarm init; else sudo docker swarm join ${vsphere_virtual_machine.swarm-manager.0.network_interface.0.ipv4_address}:2377 --token $(docker -H ${vsphere_virtual_machine.swarm-manager.0.network_interface.0.ipv4_address}:2375 swarm join-token -q manager); fi"
      ]

 }
}

# Swarm nodes
resource "vsphere_virtual_machine" "swarm-node" {
  name   = "swarm-node-${format("%02d", count.index+1)}"
  count = "${var.worker_count}"
  datacenter = "${var.vcenter_dc}"
  cluster = "${var.vcenter_cluster}"
  resource_pool = "${var.vm_resource_pool}"
  folder = "${vsphere_folder.swarm.path}"
  vcpu   = "${var.worker_cpu}"
  memory = "${var.worker_mem}"
  dns_servers = [ "10.79.255.100" ]
  depends_on = ["vsphere_virtual_machine.swarm-manager"]

  connection {
        user = "root"
        private_key = "${file("/root/.ssh/mesos.pem")}"
    }

  network_interface {
    label = "${var.vm_network}"
    ipv4_address = "${var.ip_range}${format(count.index+5)}"
    ipv4_prefix_length = "24"
    ipv4_gateway = "10.32.130.1"
  }

  disk {
    template = "${var.vm_template}"
    datastore = "${var.vm_datastore}"
    type = "thin"
  }
 provisioner "remote-exec" {
      inline = [
        "sudo docker swarm join ${vsphere_virtual_machine.swarm-manager.0.network_interface.0.ipv4_address}:2377 --token $(docker -H ${vsphere_virtual_machine.swarm-manager.0.network_interface.0.ipv4_address}:2375 swarm join-token -q worker)",
      ]


  }
}

resource "null_resource" "swarm-node" {
  # Changes to any instance of the cluster requires re-provisioning
   triggers {
   #cluster_instance_ids = "${join(",", vsphere_virtual_machine.swarm-node.*.id)}"
    cluster_instance_nb = "$(var.master_count + var.worker_count}"
  }

 connection {
    host = "${element(vsphere_virtual_machine.swarm-manager.*.network_interface.0.ipv4_address, 0)}"
    user = "root"
    private_key = "${file("/root/.ssh/mesos.pem")}"    
    #agent = false
  }

  provisioner "remote-exec" {
    inline = [
    "docker -H ${vsphere_virtual_machine.swarm-manager.0.network_interface.0.ipv4_address}:2375 node ls | grep Down | awk '{ print $1}' |  xargs docker -H ${vsphere_virtual_machine.swarm-manager.0.network_interface.0.ipv4_address}:2375 node rm",
    "docker -H ${vsphere_virtual_machine.swarm-manager.0.network_interface.0.ipv4_address}:2375 network create --driver overlay appnet || true",
    "docker -H ${vsphere_virtual_machine.swarm-manager.0.network_interface.0.ipv4_address}:2375 service create --name portainer --publish 8080:9000 --replicas=3 --constraint 'node.role == manager' --mount type=bind,src=//var/run/docker.sock,dst=/var/run/docker.sock portainer/portainer --logo ${var.logo} -H unix:///var/run/docker.sock", 
    "docker -H ${vsphere_virtual_machine.swarm-manager.0.network_interface.0.ipv4_address}:2375 service create --name viz --publish 80:8080 --constraint node.role==manager --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock --network appnet dockersamples/visualizer || true"
    ]
  }
}




