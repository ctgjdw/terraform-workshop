#images
resource "docker_image" "bgg-database" {
  name = "chukmunnlee/bgg-database:${var.database_version}"
}

resource "docker_image" "bgg-backend" {
  name = "chukmunnlee/bgg-backend:${var.backend_instance_version}"
}

resource "docker_network" "bgg-net" {
  name = "${var.app_namespace}-bgg-net"
}

resource "docker_volume" "data-vol" {
  name = "${var.app_namespace}-data-vol"
}

resource "docker_container" "bgg-database" {
  name = "${var.app_namespace}-bgg-database"
  image = docker_image.bgg-database.image_id
  
  networks_advanced {
    name = docker_network.bgg-net.id
  }

  volumes {
    volume_name = docker_volume.data-vol.name
    container_path = "/var/lib/mysql"
  }

  ports {
    internal = 3306
    external = 3306
  }
}

resource "docker_container" "bgg-backend" {
  count = var.backend_instance_count
  name = "${var.app_namespace}-bgg-backend-${count.index}"
  image = docker_image.bgg-backend.image_id

  networks_advanced {
    name = docker_network.bgg-net.id
  }

  env = [
    "BGG_DB_USER=root",
    "BGG_DB_PASSWORD=changeit",
    "BGG_DB_HOST=${docker_container.bgg-database.name}",
  ]

  ports {
    internal = 3000
  }
}

resource "local_file" "nginx-conf" {
    filename = "nginx.conf"
    content = templatefile("sample.nginx.conf.tfpl", {
        docker_host = var.docker_host
        ports = docker_container.bgg-backend[*].ports[0].external
    })
}

data "digitalocean_ssh_key" "terraform" {
  name = "terraform"
}

resource "digitalocean_droplet" "nginx-rps" {
  image  = var.do_image
  name   = "nginx-rps"
  region = var.do_region
  size   = var.do_size
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.ssh_private_key)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "apt update -y",
      "apt install -y nginx"
    ]
  }

  provisioner "file" {
    source = local_file.nginx-conf.filename
    destination = "/etc/nginx/nginx.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "nginx -t",
      "systemctl restart nginx",
      "systemctl enable nginx",
    ]
  }
}

resource "local_file" "root_at_nginx" {
    filename = "root@${digitalocean_droplet.nginx-rps.ipv4_address}"
    content = ""
    file_permission = "0444"
}

output "nginx_ip" {
  value = digitalocean_droplet.nginx-rps.ipv4_address
}

output "backend_ports" {
  value = docker_container.bgg-backend[*].ports[0].external
}