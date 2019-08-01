variable "profile" {
  default = "default"
}

variable "region" {
  default = "eu-west-1"
}

variable "ami_name" {
  default = "trusty-14.04"
}

variable amis {
  type = map
  default = {
    "eu-west-1" = "ami-63b0341a"
    "us-west-2" = "ami-4b32be2b"
  }
}

variable "gitkeyfile" {
  default = ".secrets/git_ssh_key"
}

variable "sshkeyfile" {
  default = ".secrets/ssh_key"
}

