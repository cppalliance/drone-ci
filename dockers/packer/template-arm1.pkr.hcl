#
# Packer template for drone instances
# The purpose of this step is to prepopulate the drone agents with the docker images, so they don't have
# to download multigigabyte images every time they launch. Drone will operate without packer, but there is
# a much longer delay while the docker images are pulled.
#
# Instructions:
#
# Whenever the docker images mentioned in this repo are modified and updated, packer should be re-run.
#
# export AWS_ACCESS_KEY_ID=_
# export AWS_SECRET_ACCESS_KEY=_
# packer build template-arm1.pkr.hcl 2>&1 | tee output-arm.out
#
# Use the AWS credentials for the "packer" IAM account, which has permissions in us-west-2, for isolation, and then copies
# the AMI to us-east-2 for usage. A copy of the installed IAM policy can be found in this directory.
#
# Check the resulting AMI in the target region. Copy that value into the autoscaler script on drone.cpp.al
# -e DRONE_AMAZON_IMAGE=ami-032094bbb560eeb1a \
#
# Restart the autoscaler:
# docker stop _
# ./startautoscaler.sh

variable "ami_name" {
  type    = string
  default = "my-custom-ami"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# source blocks configure your builder plugins; your source is then used inside
# build blocks to create resources. A build block runs provisioners and
# post-processors on an instance created by the source.
source "amazon-ebs" "example" {
  # access_key    = "${var.aws_access_key}"
  ami_name      = "custom drone arm ${local.timestamp}"
  instance_type = "m6g.xlarge"
  region        = "us-west-2"
  ami_regions   = ["us-east-2"]
  # secret_key    = "${var.aws_secret_key}"
  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 60
    volume_type = "gp2"
    delete_on_termination = true
  }
  source_ami = "ami-0c29a2c5cf69b5a9c"
  # 1. was ok source_ami = "ami-0c2a6ca043d888a29"
  # 2. no source_ami = "ami-00dadcba3f6d87097"
  # 3. trying source_ami = "ami-025fc2c61f9333edc"

  # source_ami_filter {
  #   filters = {
  #     virtualization-type = "hvm"
  #     architecture = "x86_64"
  #     name =  "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
  #     # block-device-mapping.volume-type = "gp2"
  #     root-device-type = "ebs"
  #   }
  #   most_recent = true
  #   owners = ["099720109477"]
  # }
  ssh_username = "ubuntu"
}

# a build block invokes sources and runs provisioning steps on them.
build {
  sources = ["source.amazon-ebs.example"]

  # earlier:
  #"sudo bash -c \"echo deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable > /etc/apt/sources.list.d/docker.list\"",

  provisioner "shell" {
    inline = [
      "set -xe",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "sudo echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release docker-ce docker-ce-cli containerd.io",
      "sudo sleep 3",
      "sudo systemctl stop docker && sleep 1",
      "sudo systemctl start docker && sleep 1",
      "sudo systemctl stop unattended-upgrades",
      "sudo systemctl disable unattended-upgrades",
      "sudo systemctl disable apt-daily-upgrade.timer",
      "sudo systemctl disable apt-daily.timer",
      "sudo fallocate -l 8G /swapfile",
      "sudo chmod 600 /swapfile",
      "sudo mkswap /swapfile",
      "sudo swapon /swapfile",
      "echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab",
      "sudo docker pull cppalliance/droneubuntu2404:multiarch",
      "sudo docker pull cppalliance/droneubuntu2204:multiarch",
      "sudo docker pull cppalliance/droneubuntu2004:multiarch",
      "sudo docker pull cppalliance/droneubuntu1804:multiarch",
      "sudo docker pull cppalliance/droneubuntu1604:multiarch",
      "sudo docker pull cppalliance/droneubuntu1404:multiarch",
      "sudo docker pull drone/git:latest"
    ]
  }
}
