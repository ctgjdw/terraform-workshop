variable "do_region" {
  type = string
  default = "sgp1"
}

variable "do_image" {
  type = string
  default = "ubuntu-20-04-x64"
}

variable "do_size" {
  type = string
  default = "s-1vcpu-512mb-10gb"
}

variable "terraform_repo" {
  type = string
  default = "https://github.com/ctgjdw/terraform-workshop.git"
}

resource "digitalocean_droplet" "control-server" {
  image  = var.do_image
  name   = "control-server"
  region = var.do_region
  size   = var.do_size
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]
  user_data = file("./init.sh")

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.pvt_key)
    timeout     = "2m"
  }

  provisioner "file" {
    source = "./do_token"
    destination = "/root/do_token"
  }

  provisioner "file" {
    source = "~/.ssh/id_rsa"
    destination = "/root/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [ 
      "chmod 400 /root/.ssh/id_rsa",
      "git clone ${var.terraform_repo}"
    ]
  }

  provisioner "remote-exec" {
    script = "./init-docker.sh"
  }
}

output "control-ipv4" {
  value = digitalocean_droplet.control-server.ipv4_address
}
