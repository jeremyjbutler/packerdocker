packer {
  required_plugins {
    docker = {
      version = ">= 1.0.8"
      source = "github.com/hashicorp/docker"
    }
     ansible = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "ansible_host" {
  default = "default"
}

variable "ansible_connection" {
  default = "docker"
}

source "docker" "ubuntu" {
  image  = "ubuntu:jammy"
  commit = true
  run_command = [ "-d", "-i", "-t", "--name", var.ansible_host, "{{.Image}}", "/bin/bash" ]
}

build {
  name    = "ubuntu_base"
  sources = [
    "source.docker.ubuntu"
  ]
  provisioner "shell" {
    environment_vars = [
      "FOO=hello world",
    ]
    inline = [
      "echo Adding file to Docker Container",
      "echo \"FOO is $FOO\" > example.txt",
    ]
  }
   provisioner "ansible" {
      playbook_file   = "./test_build.yml"
      extra_arguments = [
          "--extra-vars",
          "ansible_host=${var.ansible_host} ansible_connection=${var.ansible_connection}"
      ]
  }
}