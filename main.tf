# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.region
}

provider "random" {}

provider "time" {}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "random_pet" "instance" {
  length = 2
}

resource "aws_instance" "main" {
  count = 3

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name  = "${random_pet.instance.id}-${count.index}"
    Owner = "${var.project_name}-tutorial"
  }
}

resource "aws_s3_bucket" "example" {
  tags = {
    Name  = "Example Bucket"
    Owner = "${var.project_name}-tutorial"
  }
}
