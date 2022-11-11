
# To build:
# gcloud builds submit --config=cloudbuild.yaml .

variable "project_id" {
  type = string
}

variable "zone" {
  type = string
}

variable "builder_sa" {
  type = string
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "googlecompute" "test-image" {
  project_id                  = var.project_id
  image_name                    = "drone-x86-64-${local.timestamp}"
  source_image_family         = "ubuntu-2004-lts"
  disk_size                   = 40
  zone                        = var.zone
  temporary_key_pair_type     = "ed25519"
  image_description           = "Created with Packer from Cloudbuild"
  ssh_username                = "packer"
  tags                        = ["packer"]
  impersonate_service_account = var.builder_sa
}

build {
  sources = ["sources.googlecompute.test-image"]
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
      "sudo fallocate -l 4G /swapfile",
      "sudo chmod 600 /swapfile",
      "sudo mkswap /swapfile",
      "sudo swapon /swapfile",
      "echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab",
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

