
# note 2023-03-31. This template was tested last year. It turns out Hetzner does not support quick deployments from images,
# the way AWS does. Launches from AMIs on Hetzner are slow. So this method was shelved for the time being.

# To build:
# export HCLOUD_TOKEN=_
# packer build build.pkr.hcl

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# source "hcloud" "test-image" {
#   project_id                  = var.project_id
#   image_name                    = "drone-x86-64-${local.timestamp}"
#   source_image_family         = "ubuntu-2004-lts"
#   disk_size                   = 40
#   zone                        = var.zone
#   temporary_key_pair_type     = "ed25519"
#   image_description           = "Created with Packer from Cloudbuild"
#   ssh_username                = "packer"
#   tags                        = ["packer"]
#   impersonate_service_account = var.builder_sa
# }

source "hcloud" "test-image" {
    snapshot_name               = "drone-x86-64-${local.timestamp}"
    image			= "ubuntu-20.04"
    location			= "nbg1"
    # server_type		= "cx11"
    server_type	 		= "cx21"
    ssh_username		= "root"
    temporary_key_pair_type     = "ed25519"
}

build {
  sources = ["sources.hcloud.test-image"]
  provisioner "shell" {
inline = [
      "set -xe",
      "cd /",
      "sudo rm /var/lib/apt/lists/* -vf | true",
      "sudo apt-get clean",
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release docker.io",
      "sudo systemctl stop unattended-upgrades",
      "sudo systemctl disable unattended-upgrades",
      "sudo docker pull cppalliance/droneubuntu2204:1",
      "sudo docker pull cppalliance/droneubuntu2004:1",
      "sudo docker pull cppalliance/droneubuntu1804:1",
      "sudo docker pull cppalliance/droneubuntu1604:1",
      "sudo docker pull cppalliance/droneubuntu1404:1",
      "sudo docker pull cppalliance/droneubuntu1204:1"
    ]
}
}

 #     "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
 #     "echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
 #     "sudo apt-get update",
 #     "sudo apt-get install -y docker-ce docker-ce-cli docker-ce-rootless-extras",

# swap is causing the image to be very large. Let's remove it.
#       "sudo fallocate -l 4G /swapfile",
#       "sudo chmod 600 /swapfile",
#       "sudo mkswap /swapfile",
#       "sudo swapon /swapfile",
#       "echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab",
