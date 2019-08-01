
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

  provisioner "local-exec" {
    command = "echo [workstation] > ../provision/hosts"
    command = "echo ${aws_instance.example.public_ip} >> ../provision/hosts"
  }

  provisioner "file" { # upload the file first so it can be called with arguments
    source      = "provision.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "file" {
    source      = var.gitkeyfile
    destination = "~/.ssh/id_rsa"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = "${aws_instance.securizermaster.public_ip}"
      private_key = "${file(".secrets/ssh_key")}"

    }
  }

  provisioner "file" {
    source      = "${var.gitkeyfile}.pub"
    destination = "~/.ssh/id_rsa.pub"
  }

  provisioner "remote-exec" {
    inline = [
      "whoami",
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh argumentstothescript"
    ]
  }

  key_name               = aws_key_pair.secukey.key_name
  vpc_security_group_ids = [aws_security_group.open_ssh_sg]
}

resource "aws_eip" "ip" {
  instance = aws_instance.securizermaster.id
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

