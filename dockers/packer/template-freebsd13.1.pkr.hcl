#
# Note 2023-03-31. This was tested last year. The result was that the new type of drone runner which uses full VMs instead of
# docker container, and ought to be perfect for FreeBSD, still doesn't support FreeBSD. I had been attempting to hack it
# into having that capability.
# Hopefully in the future they will add native support for FreeBSD to that drone runner.

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
# packer build template-freebsd13.1.pkr.hcl
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
  instance_type = "m5.large"
  region        = "us-west-2"
  ami_regions   = ["us-east-2"]
  # secret_key    = "${var.aws_secret_key}"
  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 50
    volume_type = "gp2"
    delete_on_termination = true
  }
  # either specify an exact ami, or use the ami_filter below. Both methods work. The filter is likely better.
  source_ami = "ami-060ee1d1e44f2633e"
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
  ssh_username = "ec2-user"
}

# a build block invokes sources and runs provisioning steps on them.
build {
  sources = ["source.amazon-ebs.example"]

  #"sudo bash -c \"echo deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable > /etc/apt/sources.list.d/docker.list\"",

  provisioner "shell" {
    inline = [
      "su - root -c 'pkg install -y bash sudo gcc git curl go py39-cloud-init'",
      "su - root -c 'ln -s /usr/local/bin/git /usr/bin/git'",
      "su - root -c 'ln -s /usr/local/bin/bash /bin/bash'",
      "su - root -c 'ln -s /usr/local/bin/python3.9 /usr/local/bin/python3'",
      "su - root -c 'sed -i .bak \"s%^AuthorizedKeysFile%#AuthorizedKeysFile      .ssh/authorized_keys%\" /etc/ssh/sshd_config'",
      "su - root -c 'cat /etc/ssh/sshd_config'",
      "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCH0oawPzIylSjdu/fpyDD2i2stkqe52bFmLT8+MeiTAp5WI8BwlbeeiiZkneEHhLW7bGMKZ50rQONjiudWCFibb4zM2pUQTFP91BuzUG7MjFf179UlvRMUiNSYkKSSB4q0QZ8+2Vjj5lXzYxM5FjZ9FdA1ioI5l8TK8rLlf/F1TKKDfjA/YMk7769BVYndDilSidaDEvRVxQM8Z5RBUnSnDFQwEaVOuVaHIki0ZPVecwyE96e2HaFDRjNlMUZbSgHrdwkjbIugaUfiWFANBA5eIOka19CSLV5aY1tNeawoUvIBsRXjUleFJE+EIL0iGcuTcLXvAqh5UwFdMkkwUfhH drone-runner' > /home/ec2-user/.ssh/authorized_keys2",
      "chmod 700 /home/ec2-user/.ssh/authorized_keys2",
      "cat /home/ec2-user/.ssh/authorized_keys2",
      "rm /home/ec2-user/.ssh/authorized_keys",
      "mkdir -p /home/ec2-user/opt/github",
      "cd /home/ec2-user/opt/github",
      "export GOOS=freebsd",
      "export GOARCH=386",
      "git clone https://github.com/harness/lite-engine",
      "cd lite-engine",
      "go build",
      "su - root -c 'cp /home/ec2-user/opt/github/lite-engine/lite-engine /usr/bin/'",
      "su - root -c 'chmod 755 /usr/bin/lite-engine'",
      "su - root -c 'echo cloudinit_enable=YES >> /etc/rc.conf'",
      "su - root -c 'ls -al /usr/bin'",
      "su - root -c 'cat /etc/rc.conf'"
    ]
  }
}
