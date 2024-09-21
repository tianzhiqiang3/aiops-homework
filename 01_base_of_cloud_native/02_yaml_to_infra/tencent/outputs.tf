output "public_ip" {
  value = tencentcloud_instance.example[0].public_ip
  description = "Public IP of the instance"
}

output "password" {
  value = var.password
}