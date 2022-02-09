# Apply Terraform Configuration

This is a companion repository to the [Apply Terraform Configuration tutorial](https://learn.hashicorp.com/tutorials/terraform/apply) on HashiCorp Learn.


## Tutorial steps

### Clone Example Configuration

```sh
$ git clone 
```

### Review Example Configuration

### Initialize

```sh
$ terraform init
```

### Apply Configuration

```
$ terraform apply
```

### Errors During Apply

Add to `main.tf`:

```
resource "docker_image" "redis" {
  name         = "redis:latest"
  keep_locally = true
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [docker_image.redis]

  create_duration = "30s"
}

resource "docker_container" "data" {
  depends_on = [time_sleep.wait_30_seconds]
  image = docker_image.redis.latest
  name  = "data"

  ports {
    internal = 6379
    external = 6379
  }
}
```

This will create a new container with Redis, 