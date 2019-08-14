
provider "aws" {
  profile = var.profile
  region  = var.region
}

resource "aws_key_pair" "secukey" {
  key_name   = "secukey"
  public_key = "${file(".secrets/ssh_key.pub")}" #TODO: replace this with a var name from vars
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-${var.ami_name}-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_security_group" "open_ssh_sg" {
  name = "open_ssh_sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outgoing traffic to anywhere.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "securizermaster" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name               = aws_key_pair.secukey.key_name
  vpc_security_group_ids = [aws_security_group.open_ssh_sg]
}

resource "aws_eip" "ip" {
  instance = aws_instance.securizermaster.id
}

resource "null_resource" "workaround" {
  # Provide the key to access the git repositories
  provisioner "file" {
    source      = var.gitkeyfile
    destination = "/home/ubuntu/.ssh/id_rsa"

    connection {
      type        = "ssh"
      user = "ubuntu"
      private_key  = "${file(".secrets/ssh_key")}"
      host  = "${aws_eip.ip.public_ip}"
    }
  }

  # Prepare the local ansible environment
  provisioner "local-exec" {
    command = "echo [workstation] > ../provision/hosts"
    command = "echo ${aws_eip.ip.public_ip} >> ../provision/hosts"
    command = "cd provision;make run"
  }

  # TODO: Run ansible.

}

output "eip" {
  value = aws_eip.ip.public_ip
}

output "instanceip" {
  value = "${aws_instance.securizermaster.public_ip}"
}

output "command" {
  value = "ssh -i .secrets/ssh_key ${aws_eip.ip.public_ip} -vv"
}

