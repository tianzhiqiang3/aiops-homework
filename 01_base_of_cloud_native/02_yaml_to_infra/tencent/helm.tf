provider "helm" {
  kubernetes {
    config_path = "${path.module}/k3s.yaml"
  }
}

resource "helm_release" "argo_cd" {
  depends_on = [ module.k3s, null_resource.download_k3s_kubeconfig ]
  name = "argocd"
  chart = "argo-cd"
  namespace = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  create_namespace = true
}

resource "null_resource" "download_argocd_admin_password" {
  depends_on = [ helm_release.argo_cd ]
  provisioner "local-exec" {
    command = "export KUBECONFIG=${path.module}/k3s.yaml && kubectl get secret -n argocd argocd-initial-admin-secret -ojsonpath='{.data.password}' | base64 -d >> ${path.module}/argocd_admin_password"
  }
}

resource "null_resource" "port-forward" {
  depends_on = [ null_resource.download_argocd_admin_password ]
  provisioner "local-exec" {
    command = "export KUBECONFIG=${path.module}/k3s.yaml && kubectl port-forward svc/argocd-server -n argocd 8080:80"
  }
}