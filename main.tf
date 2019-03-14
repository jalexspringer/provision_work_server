provider "digitalocean" {
  token = "${var.do_api_token}"
}

resource "digitalocean_droplet" "dev_server" {
  name = "${var.server_name}"
  image = "${var.image}"
  size = "${var.server_size}"
  region = "${var.region}"
  ipv6 = true
  private_networking = false
  tags = ["${digitalocean_tag.dev.name}"]
  ssh_keys = ["${var.ssh_key_hash}"]
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF > hosts
[dev]
${digitalocean_droplet.dev_server.ipv4_address}
[dev:vars]
server=${var.server_name}
ansible_python_interpreter=/usr/bin/python3
EOF
EOD
  }
   provisioner "local-exec" {
        command = "sleep 60 && ansible-playbook -i hosts gofish.yml"
   }
}

resource "digitalocean_tag" "dev" {
  name = "dev"
}

resource "digitalocean_domain" "atcloudbase" {
  name = "${var.dev_domain}"
  ip_address = "${digitalocean_droplet.dev_server.ipv4_address}"
}

resource "digitalocean_record" "atcloudbase" {
  name = "${var.server_name}"
  type = "A"
  domain = "${digitalocean_domain.atcloudbase.name}"
  value = "${digitalocean_droplet.dev_server.ipv4_address}"
}

resource "digitalocean_firewall" "dev" {
  name = "only-ssh"
  droplet_ids = ["${digitalocean_droplet.dev_server.id}"]
  inbound_rule = [
    {
      protocol = "tcp"
      port_range = "22"
      source_addresses = ["${chomp(data.http.myip.body)}/32"]
    },
    {
      protocol = "udp"
      port_range = "60001"
      source_addresses = ["${chomp(data.http.myip.body)}/32"]
    },
    {
      protocol = "tcp"
      port_range = "80"
      source_addresses = ["0.0.0.0/0"]
    }
  ]
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}
