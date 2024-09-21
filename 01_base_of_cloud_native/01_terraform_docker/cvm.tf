provider "tencentcloud" {
  secret_id = var.secret_id
  secret_key = var.secret_key
  region = var.region
}

# 获取可用区信息
data "tencentcloud_availability_zones_by_product" "all" {
  product = "cvm"
}

# 获取镜像信息
data "tencentcloud_images" "example" {
  image_type = ["PUBLIC_IMAGE"]
  os_name = "ubuntu"
}

# 获取规格信息
data "tencentcloud_instance_types" "example" {
  filter {
    name = "instance-family"
    values = ["SA2"]
  }

  cpu_core_count = 2
  memory_size = 4
  exclude_sold_out = true
}

# 创建安全组
resource "tencentcloud_security_group" "example" {
  name = "aiops-homework-1"
}

# 创建安全组规则
resource "tencentcloud_security_group_lite_rule" "example" {
  security_group_id = tencentcloud_security_group.example.id
  ingress = ["ACCEPT#0.0.0.0/0#22#TCP"]
  egress = ["ACCEPT#0.0.0.0/0#ALL#ALL"]
}

# 创建实例
resource "tencentcloud_instance" "example" {
  instance_name = "aiops-homework-1"
  availability_zone = data.tencentcloud_availability_zones_by_product.all.zones[0].name
  image_id = data.tencentcloud_images.example.images[0].image_id
  instance_type = data.tencentcloud_instance_types.example.instance_types[0].instance_type
  count = 1
  system_disk_type = "CLOUD_PREMIUM"
  system_disk_size = 50
  allocate_public_ip = true
  # The combination of parameters between .InternetAccessible.PublicIpAssigned and InternetMaxBandwidthOut is incorrect.
  internet_max_bandwidth_out = 100
  password = var.password
  instance_charge_type = "SPOTPAID"
  depends_on = [tencentcloud_security_group_lite_rule.example]
}

resource "null_resource" "install_docker" {
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      host = tencentcloud_instance.example[0].public_ip
      user = "ubuntu"
      password = var.password
    }

    inline = [ 
      "sudo apt-get update",
      "sudo apt-get install ca-certificates curl -y",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc",
      "sudo chmod a+r /etc/apt/keyrings/docker.asc",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null ",
      "sudo apt-get update",
      "sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y"
     ]
  }
}