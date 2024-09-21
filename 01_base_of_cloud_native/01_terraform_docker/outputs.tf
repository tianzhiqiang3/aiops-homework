output "public_ip" {
  value = tencentcloud_instance.example[0].public_ip
}

output "password" {
  value = var.password
}