
variable "hcloud_token1" {
  sensitive = true
}
# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = "${var.hcloud_token1}"
}
#  Main ssh key
resource "hcloud_ssh_key" "default" {
  name       = "main ssh key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}
### Server creation with one linked primary ip (ipv4)
resource "hcloud_primary_ip" "primary_ip_1" {
  name          = "primary_ip_test"
  datacenter    = "fsn1-dc14"
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = true
  labels = {
    "hallo" : "systema"
  }
}


resource "hcloud_server" "server_test" {
  name        = "test-server-please-ignore"
  image       = "ubuntu-22.04"
  server_type = "cx11"
  datacenter  = "fsn1-dc14"
  ssh_keys    = ["${hcloud_ssh_key.default.name}"]
  labels = {
    "hallo" : "systema"
  }
  public_net {
    ipv4_enabled = true
    ipv4 = hcloud_primary_ip.primary_ip_1.id
    ipv6_enabled = false
  }

  depends_on = [ hcloud_primary_ip.primary_ip_1 ]
}
output "public_ip4" {
  value = "${hcloud_server.server_test.ipv4_address}"
}