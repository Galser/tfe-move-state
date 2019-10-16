# tfe-move-state
TFE state moving

# Goal
Start with 1 folder with multiple state, end with 2 folder, separate state and remote state.
The goal of this lab is move the state into separate projects.

# Description
We will create 1 folder, and then we will separate into 2 different projects.

# Instructions

- Create 1 folder for sample code - random_pet and null provider [main.tf](main.tf):
    ```terraform
    resource "null_resource" "helloWorld" {
      provisioner "local-exec" {
        command = "echo hello world"
      }
    }

    resource "random_pet" "demo" { }

    output "demo" {
      value = "${random_pet.demo.id}"
    }
    ```
- Terraform init
- Run terraform apply, you should end with a new repo created, and state locally :
    ```bash