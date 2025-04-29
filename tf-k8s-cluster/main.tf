terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

variable "nodes" {
  default = [
    { name = "dama-node-1", ip = "15.1.1.11" },
    { name = "dama-node-2", ip = "15.1.1.12" },
    { name = "dama-node-3", ip = "15.1.1.13" }
  ]
}

resource "libvirt_volume" "k8s_disk" {
  count  = length(var.nodes)
  name   = "${var.nodes[count.index].name}.qcow2"
  pool   = "vms"
  base_volume_name = "ubuntu-noble.img"
  base_volume_pool = "isos"
  format = "qcow2"
  size   = "107374182400"
}

resource "libvirt_cloudinit_disk" "cloudinit" {
  count     = length(var.nodes)
  name      = "${var.nodes[count.index].name}-init.iso"
  user_data = file("${path.module}/cloud-init/cloud-${var.nodes[count.index].name}.yaml")
  network_config = file("${path.module}/cloud-init/net-${var.nodes[count.index].name}.yaml")
}

resource "libvirt_domain" "k8s_node" {
  count  = length(var.nodes)
  name   = var.nodes[count.index].name
  memory = 8192
  vcpu   = 4
  machine = "pc"


  disk {
    volume_id = libvirt_volume.k8s_disk[count.index].id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_port = "1"
    target_type = "virtio"
  }  

  network_interface {
    network_name = "dama-data-net"
    addresses    = [var.nodes[count.index].ip]
  }

  video {
    type = "vga"
  }

  graphics {
    type = "vnc"
    listen_type = "address"
    autoport = true
 }

  cloudinit = libvirt_cloudinit_disk.cloudinit[count.index].id
}

