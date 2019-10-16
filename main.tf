resource "null_resource" "helloWorld" {
    provisioner "local-exec" {
    command = "echo hello world"
    }
}

resource "random_pet" "demo" { }

output "demo" {
    value = "${random_pet.demo.id}"
}