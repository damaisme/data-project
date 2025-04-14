resource "libvirt_network" "data_network" {
  name      = "data-net"
  mode      = "nat"
  domain    = "data.local"
  addresses = ["15.1.1.0/24"]

  dhcp {
    enabled = true

    dhcp_range {
      start = "15.1.1.100"
      end   = "15.1.1.200"
    }
  }
}

