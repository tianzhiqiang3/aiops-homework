module "k3s" {
  source  = "xunleii/k3s/module"
  version = "3.4.0"
  drain_timeout = "60s"
  generate_ca_certificates = true
  global_flags = [
    "--tls-san=${tencentcloud_instance.example[0].public_ip}",
    "--disable=traefik",
    "--write-kubeconfig-mode 644",
    "--kube-controller-manager-arg bind-address=0.0.0.0",
    "--kube-proxy-arg metrics-bind-address=0.0.0.0",
    "--kube-scheduler-arg bind-address=0.0.0.0"
  ]
  k3s_install_env_vars = {}
  servers = {
    "aiops-homework-04" = {
      ip = tencentcloud_instance.example.0.private_ip
      connection = {
        timeout = "60s"
        type = "ssh"
        user = "ubuntu"
        password = var.password
        host = tencentcloud_instance.example.0.public_ip
      }
    }
  }
}

resource "null_resource" "fetch_kubeconfig" {
  depends_on = [ module.k3s ]
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      host = tencentcloud_instance.example.0.public_ip
      user = "ubuntu"
      password = var.password
      timeout = "30s"
    }

    inline = [ 
      "mkdir ~/.ssh",
      "echo '${file("${path.module}/ssh/id_rsa.pub")}' >> ~/.ssh/authorized_keys",
      "chmod 700 ~/.ssh",
      "chmod 600 ~/.ssh/authorized_keys",
      
      "sudo cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/k3s.yaml",
      "sudo chown ubuntu:ubuntu /home/ubuntu/k3s.yaml",
      "sed -i 's/127.0.0.1/${tencentcloud_instance.example.0.public_ip}/g' /home/ubuntu/k3s.yaml"
     ]
  }
}

resource "null_resource" "download_k3s_kubeconfig" {
  depends_on = [ null_resource.fetch_kubeconfig ]
  provisioner "local-exec" {
    command = "scp -i ${path.module}/ssh/id_rsa -o StrictHostKeyChecking=no ubuntu@${tencentcloud_instance.example.0.public_ip}:/home/ubuntu/k3s.yaml ${path.module}/k3s.yaml"
  }
}