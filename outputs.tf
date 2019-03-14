output "instance_ip_addr" {
  value = "${digitalocean_droplet.dev_server.ipv4_address}"
}
