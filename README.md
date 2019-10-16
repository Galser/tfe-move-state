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
    An execution plan has been generated and is shown below.
    Resource actions are indicated with the following symbols:
    + create

    Terraform will perform the following actions:

    # null_resource.helloWorld will be created
    + resource "null_resource" "helloWorld" {
        + id = (known after apply)
        }

    # random_pet.demo will be created
    + resource "random_pet" "demo" {
        + id        = (known after apply)
        + length    = 2
        + separator = "-"
        }

    Plan: 2 to add, 0 to change, 0 to destroy.

    Do you want to perform these actions?
    Terraform will perform the actions described above.
    Only 'yes' will be accepted to approve.

    Enter a value: yes

    null_resource.helloWorld: Creating...
    null_resource.helloWorld: Provisioning with 'local-exec'...
    null_resource.helloWorld (local-exec): Executing: ["/bin/sh" "-c" "echo hello world"]
    null_resource.helloWorld (local-exec): hello world
    null_resource.helloWorld: Creation complete after 0s [id=3406884272144719649]
    random_pet.demo: Creating...
    random_pet.demo: Creation complete after 0s [id=proud-antelope]

    Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

    Outputs:

    demo = proud-antelope
    ``` 
    Let's check part of the satet file content : 
    ```json
    {
    "version": 4,
    "terraform_version": "0.12.9",
    "serial": 1,
    "lineage": "40f30e77-a897-382f-4703-2ca19c5226f1",
    "outputs": {},
    "resources": [
        {
        "mode": "managed",
        "type": "random_pet",
        "name": "demo",
        "provider": "provider.random",
        "instances": [
            {
            "schema_version": 0,
            "attributes": {
                "id": "proud-antelope",
    ...
    ```
    Okay, note down the value for random_pet - **proud-antelope**
- Create a folder for random_pet
    ```
    mkdir random_pet
    ```
    - Split code, move the state :
        ```bash
        terraform state mv -state-out=random_pet/terraform.tfstate random_pet.demo random_pet.demo
        Move "random_pet.demo" to "random_pet.demo"
        Successfully moved 1 object(s).
        ```
    - add a remote state backend to state; push to TFE. 
        Now file [random_pet/main.tf](random_pet/main.tf) looks like :
        ```terraform
        terraform {
            backend "atlas" {
                name    = "galser-paid/random-pet"
            }
        }

        resource "random_pet" "demo" { }

        output "demo" {
            value = "${random_pet.demo.id}"
        }        
        ```
        Moving state :
        ```bash
        $ cd random_pet
        $ terraform init
        Initializing the backend...
        Do you want to copy existing state to the new backend?
        Pre-existing state was found while migrating the previous "local" backend to the
        newly configured "atlas" backend. No existing state was found in the newly
        configured "atlas" backend. Do you want to copy this state to the new "atlas"
        backend? Enter "yes" to copy and "no" to start with an empty state.

        Enter a value: yes


        Successfully configured the backend "atlas"! Terraform will automatically
        use this backend unless the backend configuration changes.

        Initializing provider plugins...
        - Checking for available provider plugins...
        - Downloading plugin for provider "random" (hashicorp/random) 2.2.1...

        The following providers do not have any version constraints in configuration,
        so the latest version was installed.

        To prevent automatic upgrades to new major versions that may contain breaking
        changes, it is recommended to add version = "..." constraints to the
        corresponding provider blocks in configuration, with the constraint strings
        suggested below.

        * provider.random: version = "~> 2.2"

        Terraform has been successfully initialized!
        ```
        As you can see Terraform asked us about moving existing state into TFE, and the answer is `yes`
        Now, as Terraform has been successfully initialized! We can check state in TFE : `New state #sv-w3DrGgi89JRbaamD` :
        ```json
        {
        "version": 4,
        "terraform_version": "0.12.9",
        "serial": 0,
        "lineage": "44e5dbd1-9625-b269-5a63-90156f64034b",
        "outputs": {},
        "resources": [
            {
            "mode": "managed",
            "type": "random_pet",
            "name": "demo",
            "provider": "provider.random",
            "instances": [
                {
                "schema_version": 0,
                "attributes": {
                    "id": "proud-antelope",
                    "keepers": null,
        ```
        OKay so far all looks good.
- Update code to reference the remote state
  reference the state on random_pet 
  > Note: not sure this will work, lets try
  Editing [main.tf](main.tf) to make it look like :
  ```terraform
    data "terraform_remote_state" "random-pet" {
        backend = "remote" 

        config = {
            organization = "galser-paid"
            workspaces = {
            name = "random-pet"
            }      
        }
     }

    resource "null_resource" "helloWorld" {
        provisioner "local-exec" {
            command = "echo hello world"
        }
    }

    output "remote_demo" {
       value = "${data.terraform_remote_state.random-pet.outputs.demo}"
    }
  ```

- Terraform apply should say the nothing to be created, state should persists. Let's try terraform apply :
    ```bash
    terraform apply
    null_resource.helloWorld: Refreshing state... [id=3406884272144719649]
    data.terraform_remote_state.random-pet: Refreshing state...

    Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

    Outputs:

    remote_demo = proud-antelope
    ```
    As you can see indeed, state persist. nothign changed, created or adde, yet we go back, the very value for random_pet - **proud-antelope**
- Terraform destroy should work and delete the existing state. Let's try to destroy state :
    ```bash
    $ terraform destroy
    null_resource.helloWorld: Refreshing state... [id=3406884272144719649]
    data.terraform_remote_state.random-pet: Refreshing state...

    An execution plan has been generated and is shown below.
    Resource actions are indicated with the following symbols:
    - destroy

    Terraform will perform the following actions:

    # null_resource.helloWorld will be destroyed
    - resource "null_resource" "helloWorld" {
        - id = "3406884272144719649" -> null
        }

    Plan: 0 to add, 0 to change, 1 to destroy.

    Do you really want to destroy all resources?
    Terraform will destroy all your managed infrastructure, as shown above.
    There is no undo. Only 'yes' will be accepted to confirm.

    Enter a value: yes

    null_resource.helloWorld: Destroying... [id=3406884272144719649]
    null_resource.helloWorld: Destruction complete after 0s

    Destroy complete! Resources: 1 destroyed.
    ```
    Double-check : 
    ```
    terraform show
    ```
    ( Came empty ) . E.g. there is no state to show.


# DONE
- [x] initial code
- [x] split code and move state
- [x] update code and try to reference remote state

