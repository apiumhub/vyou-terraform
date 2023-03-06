resource "time_sleep" "vyou_resources_deletion_trigger" {
  depends_on = [
    aws_eks_cluster.eks_cluster, 
    aws_eks_node_group.eks_cluster_node_group, 
    helm_release.backube_snapscheduler,
    helm_release.lb_controller]

  destroy_duration = "120s"
}

resource "helm_release" "vyou_services" {
  depends_on = [time_sleep.vyou_resources_deletion_trigger]
  name       = "vyou-services"
  chart      = "vyou-services"
  repository = "https://apiumhub.github.io/vyou-helm-charts"
  version    = "1.0.0"
  namespace  = "default"

  set {
    name  = "core.targetPlatform"
    value = "eks"
  }
  set {
    name  = "core.iss"
    value = var.vyou_iss
  }
  set {
    name  = "core.allowedOrigins"
    value = var.vyou_allowed_origins
  }
  set {
    name  = "core.webUser"
    value = var.vyou_web_user
  }
  set {
    name  = "core.webPassword"
    value = var.vyou_web_password
  }
  set {
    name  = "core.migrationUser"
    value = var.vyou_migration_user
  }
  set {
    name  = "core.migrationPassword"
    value = var.vyou_migration_password
  }
  set {
    name  = "core.vYouSubdomain"
    value = var.vyou_subdomain
  }
  set {
    name  = "core.awsEksCertificateArn"
    value = aws_acm_certificate.vyou_ssl_cert.arn
  }

  set {
    name  = "backend.version"
    value = var.vyou_backend_version
  }
  set {
    name  = "backend.authServer"
    value = var.vyou_auth_server
  }
  set {
    name  = "backend.enableAlipay"
    value = var.vyou_enable_alipay
  }
  set {
    name  = "backend.emailSendgridKey"
    value = var.vyou_sendgrid_key
  }
  set {
    name  = "backend.licenseKey"
    value = var.vyou_license_key
  }
  set {
    name  = "backend.licenseSecret"
    value = var.vyou_license_secret
  }
  set {
    name  = "backend.tenantGodPassword"
    value = var.vyou_tenant_god_password
  }
  set {
    name  = "backend.tenantGod"
    value = var.vyou_tenant_god
  }
  set {
    name  = "backend.stripeHookSecret"
    value = var.vyou_stripe_hook_secret
  }

  set {
    name  = "db.version"
    value = var.vyou_db_version
  }
  set {
    name  = "db.developerUser"
    value = var.vyou_developer_user
  }
  set {
    name  = "db.developerPassword"
    value = var.vyou_developer_password
  }
  set {
    name  = "db.postgresUser"
    value = var.vyou_db_user
  }
  set {
    name  = "db.postgresPassword"
    value = var.vyou_db_password
  }
  set {
    name  = "db.dataPVCName"
    value = "pgdata"
  }
  set {
    name  = "db.volumeSize"
    value = "40Gi"
  }

  set {
    name  = "proxy.version"
    value = var.vyou_proxy_version
  }
  set {
    name  = "proxy.nginxJson"
    value = filebase64("${path.module}/nginx.json")
  }
  set {
    name  = "proxy.sslChain"
    value = filebase64("${path.module}/chain.pem")
  }
  set {
    name  = "proxy.sslFullchain"
    value = filebase64("${path.module}/fullchain.pem")
  }
  set {
    name  = "proxy.sslKey"
    value = filebase64("${path.module}/key.pem")
  }
}
