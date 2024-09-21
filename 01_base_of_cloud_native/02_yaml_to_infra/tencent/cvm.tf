# terraform-provider-tencentcloud
provider "tencentcloud" {
  secret_id = var.secret_id
  secret_key = var.secret_key
  region = var.region
}

# 查询可用区
data "tencentcloud_availability_zones_by_product" "all" {
  product = "cvm"
}

# 查询规格
data "tencentcloud_instance_types" "example" {
  availability_zone = "ap-hongkong-3"
  cpu_core_count = 2
  memory_size = 4
  exclude_sold_out = true
}
# 查询镜像
data "tencentcloud_images" "example" {
  image_type = ["PUBLIC_IMAGE"]
  os_name = "ubuntu"
}

# 创建VPC
resource "tencentcloud_vpc" "example" {
  cidr_block = "10.1.0.0/16"
  name = "aiops-homework-2"
}

# 创建子网
resource "tencentcloud_subnet" "example" {
  availability_zone = "ap-hongkong-3"
  cidr_block = "10.1.1.0/24"
  name = "aiops-homework-2"
  vpc_id = tencentcloud_vpc.example.id
}

# 创建安全组
resource "tencentcloud_security_group" "example" {
  name        = "aiops-homework-2"
}

# 创建安全组规则
resource "tencentcloud_security_group_lite_rule" "example" {
  security_group_id = tencentcloud_security_group.example.id
  ingress = [
    "ACCEPT#0.0.0.0/0#22#TCP",
    "ACCEPT#0.0.0.0/0#6443#TCP",
  ]
  egress = [ 
    "ACCEPT#0.0.0.0/0#ALL#ALL"
   ]
}

# 创建实例
resource "tencentcloud_instance" "example" {
  availability_zone = "ap-hongkong-3"
  image_id = data.tencentcloud_images.example.images.0.image_id
  allocate_public_ip = true
  internet_max_bandwidth_out = 100
  instance_charge_type = "SPOTPAID"
  count = 1
  instance_name = "aiops-homework-2"
  password = var.password
  orderly_security_groups = [tencentcloud_security_group.example.id]
  system_disk_type = "CLOUD_PREMIUM"
  system_disk_size = 50
  vpc_id = tencentcloud_vpc.example.id
  subnet_id = tencentcloud_subnet.example.id
}