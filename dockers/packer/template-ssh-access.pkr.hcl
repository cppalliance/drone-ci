#
# Note 2023-03-31. Last year, there was an issue with ssh into certain drone runners. 
# This image was being built with ssh keys included to solve that.


# Test to be able to ssh into a drone vm
#
# Instructions:
#
# Whenever the docker images mentioned in this repo are modified and updated, packer should be re-run.
#
# export AWS_ACCESS_KEY_ID=_
# export AWS_SECRET_ACCESS_KEY=_
# packer build template-ssh-access.pkr.hcl
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
  ami_name      = "custom drone ${local.timestamp}"
  instance_type = "t2.xlarge"
  region        = "us-west-2"
  ami_regions   = ["us-east-2"]
  # secret_key    = "${var.aws_secret_key}"
  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 40
    volume_type = "gp2"
    delete_on_termination = true
  }
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      architecture = "x86_64"
      name =  "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      # block-device-mapping.volume-type = "gp2"
      root-device-type = "ebs"
    }
    most_recent = true
    owners = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

# a build block invokes sources and runs provisioning steps on them.
build {
  sources = ["source.amazon-ebs.example"]

  #"sudo bash -c \"echo deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable > /etc/apt/sources.list.d/docker.list\"",

  provisioner "shell" {
    inline = [
      "set -xe",
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release",
      "sudo systemctl stop unattended-upgrades",
      "sudo systemctl disable unattended-upgrades",
      "sudo sed -i \"s%^AuthorizedKeysFile%#AuthorizedKeysFile      .ssh/authorized_keys%\" /etc/ssh/sshd_config",
      "cat /etc/ssh/sshd_config",
      "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCH0oawPzIylSjdu/fpyDD2i2stkqe52bFmLT8+MeiTAp5WI8BwlbeeiiZkneEHhLW7bGMKZ50rQONjiudWCFibb4zM2pUQTFP91BuzUG7MjFf179UlvRMUiNSYkKSSB4q0QZ8+2Vjj5lXzYxM5FjZ9FdA1ioI5l8TK8rLlf/F1TKKDfjA/YMk7769BVYndDilSidaDEvRVxQM8Z5RBUnSnDFQwEaVOuVaHIki0ZPVecwyE96e2HaFDRjNlMUZbSgHrdwkjbIugaUfiWFANBA5eIOka19CSLV5aY1tNeawoUvIBsRXjUleFJE+EIL0iGcuTcLXvAqh5UwFdMkkwUfhH drone-runner' > /home/ubuntu/.ssh/authorized_keys2",
      "chmod 700 /home/ubuntu/.ssh/authorized_keys2",
      "cat /home/ubuntu/.ssh/authorized_keys2",
      "rm /home/ubuntu/.ssh/authorized_keys"
    ]
  }
}
