# Apply Terraform Configuration

This is a companion repository to the [Apply Terraform Configuration](https://learn.hashicorp.com/tutorials/terraform/apply) tutorial on HashiCorp Learn.


# Tutorial steps

## Clone Example Configuration

```sh
$ git clone https://github.com/hashicorp/learn-terraform-apply.git
```

## Review Example Configuration

`main.tf` includes configuration to deploy four nginx containers on Docker.

## Initialize

```sh
$ terraform init
```

### Apply Configuration

Apply the config, respond to confirmation prompt with a `yes`.

```
$ terraform apply
```

When Terraform applies configuration...

### Errors During Apply

Add to `main.tf`:

```hcl
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

Open a second terminal window.

In the first, apply the configuration. Respond to confirmation prompt with a
`yes`.

Terraform will create the `docker_image.redis` resource, then pause for 30
seconds while waiting for the `time_sleep.wait_30_seconds` resource.

```sh
$ terraform apply
docker_image.nginx: Refreshing state... [id=sha256:c316d5a335a5cf324b0dc83b3da82d7608724769f6454f6d9a621f3ec2534a5anginx:latest]
random_pet.dog: Refreshing state... [id=fun-monarch]
docker_container.nginx[0]: Refreshing state... [id=2fc3e95dc32694229a8c19b056a5fdf56ac40d0bd8ddf981ddd2cfbd144b1bcc]
##...

Plan: 3 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

docker_image.redis: Creating...
docker_image.redis: Creation complete after 0s [id=sha256:f1b6973564e91aecb808142499829a15798fdc783a30de902bb0c4133fee19adredis:latest]
time_sleep.wait_30_seconds: Creating...
```

**Within 30 seconds**, switch to the new tab and remove the redis image from
Docker.

```sh
$ docker image rm redis:latest
Untagged: redis:latest
Untagged: redis@sha256:0d9c9aed1eb385336db0bc9b976b6b49774aee3d2b9c2788a0d0d9e239986cb3
Deleted: sha256:f1b6973564e91aecb808142499829a15798fdc783a30de902bb0c4133fee19ad
Deleted: sha256:5248e4fce7def91a350b6b4a6cb1123dab9c98075b44b6663c4994b4c680d23c
Deleted: sha256:555a11039e3c07f6ae3bc768248babe5db27eba042ed41cee9375c39a6e14bd4
Deleted: sha256:d59e9b328a1c924de9e59ea95b4c0dabf7b5f1ba834bb00f7cdfdf63020baba7
Deleted: sha256:ace8e13527f7c6e1e837e8235453a742e9675d28476a34f4639673bd89bb59d1
Deleted: sha256:f0083cf24bd0ba36ca8075baa8f2c9a46ffe382c9f865e5e245e682acfbe923c
```

Return to the tab where `terraform apply` is running. Because you removed the
image from Docker after Terraform provisioned it, Terraform will error out when
it tries to create the `docker_container.data` container.

```sh
time_sleep.wait_30_seconds: Still creating... [10s elapsed]
time_sleep.wait_30_seconds: Still creating... [20s elapsed]
time_sleep.wait_30_seconds: Creation complete after 30s [id=2022-02-09T19:33:18Z]
docker_container.data: Creating...
╷
│ Error: Unable to create container with image sha256:f1b6973564e91aecb808142499829a15798fdc783a30de902bb0c4133fee19ad: unable to pull image sha256:f1b6973564e91aecb808142499829a15798fdc783a30de902bb0c4133fee19ad: error pulling image sha256:f1b6973564e91aecb808142499829a15798fdc783a30de902bb0c4133fee19ad: Error response from daemon: pull access denied for sha256, repository does not exist or may require 'docker login': denied: requested access to the resource is denied
│ 
│   with docker_container.data,
│   on main.tf line 57, in resource "docker_container" "data":
│   57: resource "docker_container" "data" {
│ 
╵
```

When a Terraform apply step errors out, your configuration changes may be
partially applied. Terraform does not attempt undo or roll back changes when an
apply errors out.

Common reasons for an apply to error include:

1. A change to a resource outside of Terraform's control.
1. Networking or other transient errors.
1. An expected error from the upstream API, such as a duplicate resource name or hitting a resource limit.
1. An unexpected error from the upstream API, such as an internal server error.
1. A bug in the Terraform provider code, or Terraform itself.

Depending on the cause of the error, you may need to resolve the underlying
issue either by making changes to your configuration or diagnosing and resolving
the error from the cloud provider API. In this case, you can recover from the
issue by re-running `terraform apply`.

```sh
$ terraform apply
random_pet.dog: Refreshing state... [id=fun-monarch]
docker_image.redis: Refreshing state... [id=sha256:f1b6973564e91aecb808142499829a15798fdc783a30de902bb0c4133fee19adredis:latest]
docker_image.nginx: Refreshing state... [id=sha256:c316d5a335a5cf324b0dc83b3da82d7608724769f6454f6d9a621f3ec2534a5anginx:latest]
time_sleep.wait_30_seconds: Refreshing state... [id=2022-02-09T19:33:18Z]
docker_container.nginx[0]: Refreshing state... [id=2fc3e95dc32694229a8c19b056a5fdf56ac40d0bd8ddf981ddd2cfbd144b1bcc]
docker_container.nginx[3]: Refreshing state... [id=3046090083d0e6548e11d56104f3ef08f2bbb6d588dc7712ebcb9aab1ee4c8d2]
docker_container.nginx[1]: Refreshing state... [id=d2a741c7884b5733360660d5c4a9cf66b4cd6a5829c1bbdcd2aa3ae6042fbdaf]
docker_container.nginx[2]: Refreshing state... [id=e869c4965ee269f62c93a09ad986af14d7ada4cdc2f6aa7a3968d2b7536e7963]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the last "terraform apply":

  # docker_image.redis has been deleted
  - resource "docker_image" "redis" {
      - id           = "sha256:f1b6973564e91aecb808142499829a15798fdc783a30de902bb0c4133fee19adredis:latest" -> null
      - keep_locally = true -> null
      - latest       = "sha256:f1b6973564e91aecb808142499829a15798fdc783a30de902bb0c4133fee19ad" -> null
      - name         = "redis:latest" -> null
      - repo_digest  = "redis@sha256:0d9c9aed1eb385336db0bc9b976b6b49774aee3d2b9c2788a0d0d9e239986cb3" -> null
    }


Unless you have made equivalent changes to your configuration, or ignored the relevant attributes using ignore_changes, the following plan may
include actions to undo or respond to these changes.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # docker_container.data will be created
  + resource "docker_container" "data" {
      + attach           = false
      + bridge           = (known after apply)
      + command          = (known after apply)
      + container_logs   = (known after apply)
      + entrypoint       = (known after apply)
      + env              = (known after apply)
      + exit_code        = (known after apply)
      + gateway          = (known after apply)
      + hostname         = (known after apply)
      + id               = (known after apply)
      + image            = (known after apply)
      + init             = (known after apply)
      + ip_address       = (known after apply)
      + ip_prefix_length = (known after apply)
      + ipc_mode         = (known after apply)
      + log_driver       = (known after apply)
      + logs             = false
      + must_run         = true
      + name             = "data"
      + network_data     = (known after apply)
      + read_only        = false
      + remove_volumes   = true
      + restart          = "no"
      + rm               = false
      + security_opts    = (known after apply)
      + shm_size         = (known after apply)
      + start            = true
      + stdin_open       = false
      + tty              = false

      + healthcheck {
          + interval     = (known after apply)
          + retries      = (known after apply)
          + start_period = (known after apply)
          + test         = (known after apply)
          + timeout      = (known after apply)
        }

      + labels {
          + label = (known after apply)
          + value = (known after apply)
        }

      + ports {
          + external = 6379
          + internal = 6379
          + ip       = "0.0.0.0"
          + protocol = "tcp"
        }
    }

  # docker_image.redis will be created
  + resource "docker_image" "redis" {
      + id           = (known after apply)
      + keep_locally = true
      + latest       = (known after apply)
      + name         = "redis:latest"
      + output       = (known after apply)
      + repo_digest  = (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: 
```

Before Terraform created the plan, it refreshed the state of your resources by calling the Docker API. Terraform noticed that `docker_image.redis` had been deleted outside of Terraform's control, and plans to recreate it before creating `docker_container.data`, which relies on the image.

Respond to the confirmatio prompt with a `yes` to provision the redis image and container.

## Replace Resources

When using Terraform's intended workflow, you will apply an entire configuration
change at once, and Terraform and its providers will determine the changes to
make, and what order to make them in. There are some cases where you may need to
replace or modify individual resources, however.

First, sometimes a resource will become compromised or stop working in ways that
are outside of Terraform's control. For instance, a misconfiguration or error in
your Docker container's OS configuration could require that the container be
replaced. Terraform supports this through the `-replace` command line argument.

Replace one of your Docker containers. Respond to the confirmation prompt with a
`yes`.

```sh
$ terraform apply -replace 'docker_container.nginx[1]'
random_pet.dog: Refreshing state... [id=fun-monarch]
docker_image.nginx: Refreshing state... [id=sha256:c316d5a335a5cf324b0dc83b3da82d7608724769f6454f6d9a621f3ec2534a5anginx:latest]
docker_image.redis: Refreshing state... [id=sha256:f1b6973564e91aecb808142499829a15798fdc783a30de902bb0c4133fee19adredis:latest]
time_sleep.wait_30_seconds: Refreshing state... [id=2022-02-09T19:33:18Z]
##...

Terraform will perform the following actions:

  # docker_container.nginx[1] will be replaced, as requested
-/+ resource "docker_container" "nginx" {
      + bridge            = (known after apply)
      ~ command           = [
          - "nginx",
          - "-g",
          - "daemon off;",
        ] -> (known after apply)

##...

Plan: 1 to add, 0 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

docker_container.nginx[1]: Destroying... [id=d2a741c7884b5733360660d5c4a9cf66b4cd6a5829c1bbdcd2aa3ae6042fbdaf]
docker_container.nginx[1]: Destruction complete after 2s
docker_container.nginx[1]: Creating...
docker_container.nginx[1]: Creation complete after 1s [id=5d23d3b445f5beadcf475987cf62827ea1616d727a2085b123bdf9e2100ae720]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
```

The `-replace` argument takes a Terraform resource ID, and can be used more than
once for a given plan or apply command. You can list the IDs of your resources
with `terraform state list`.

The second case where you may need to partially apply configuration is when
troubleshooting an error when applying configuration changes. You can use the
`-target` command line argument when you apply to target individual resources.
Refer to the [Target resources](https://learn.hashicorp.com/tutorials/terraform/resource-targeting)
tutorial for more information.

## Clean up

```sh
$ terraform destroy
```

## Next steps

