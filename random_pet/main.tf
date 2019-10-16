
terraform {
  backend "atlas" {
    name    = "galser-paid/random-pet"
  }
}

resource "random_pet" "demo" { }

output "demo" {
  value = "${random_pet.demo.id}"
}
