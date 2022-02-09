terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.16.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.7.2"
    }
  }
}

provider "docker" {}

provider "random" {}

provider "time" {}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}

resource "random_pet" "dog" {
  length = 2
}

resource "docker_container" "nginx" {
  count = 4
  image = docker_image.nginx.latest
  name  = "nginx-${random_pet.dog.id}-${count.index}"

  ports {
    internal = 80
    external = 8000 + count.index
  }
}
