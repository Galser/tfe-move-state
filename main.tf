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
