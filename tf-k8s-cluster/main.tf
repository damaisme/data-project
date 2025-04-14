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
  pool   = "default"
  source = "/data/isos/ubuntu-jammy.qcow2"
  format = "qcow2"
}

resource "libvirt_cloudinit_disk" "cloudinit" {
  count     = length(var.nodes)
  name      = "${var.nodes[count.index].name}-init.iso"
  user_data = file("${path.module}/cloud-init/node.yaml")
}

resource "libvirt_domain" "k8s_node" {
  count  = length(var.nodes)
  name   = var.nodes[count.index].name
  memory = 8192
  vcpu   = 4

  disk {
    volume_id = libvirt_volume.k8s_disk[count.index].id
  }

  network_interface {
    network_name = "dama-data-net"
    addresses    = [var.nodes[count.index].ip]
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit[count.index].id
}

