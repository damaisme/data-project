resource "libvirt_network" "data_network" {
  name      = "dama-data-net"
  mode      = "nat"
  domain    = "data.local"
  addresses = ["15.1.1.0/24"]

  dhcp {
    enabled = true
  }
}

