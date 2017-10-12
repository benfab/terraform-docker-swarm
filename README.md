# terraform-docker-swarm

This repo contains an example of infrastucture-as-code on vSphere. It demonstrates how Terraform ensures that a Docker Swarm cluster is matching a desired state defined.

## Requirements
- Access to vSphere API
- CentOS 7 template with Docker CE installed
- Terraform 0.10.6

## Demo

1. Edit the file desired_state.tf with your values. 

2. Run terraform
 
   `terraform init` 
  
   `terraform apply`

3. Browse the Swarm cluster with Portainer web interface

http://master-ip:8080
Go to Swarm then click on "Go to cluster visualizer"

3. Update the desired_state.tf file by increasing or decreasing the number of worker node

4. Run terraform again 

   `terraform apply`

5. Tear down your cluster

   `terraform destroy`

# Steps to install Docker on the CentOS7 template

Install Docker-ce
```
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker -y
```

Create one file at  /etc/systemd/system/docker.service.d/docker.conf
Paste the content

```
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock
```

Configure the firewall
```
firewall-cmd --add-port=22/tcp --permanent
firewall-cmd --add-port=2376/tcp --permanent
firewall-cmd --add-port=7946/tcp --permanent
firewall-cmd --add-port=7946/udp --permanent
firewall-cmd --add-port=4789/udp --permanent
firewall-cmd --reload
```

Start docker daemon at boot time
```
systemctl enable docker
systemctl restart docker
```


