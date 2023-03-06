variable "project_id" {
  description = "Id of the project. Only lowercase and dashes allowed (-,a-z)."
  type        = string
}
variable "aws_region" {
  description = "Region to use to create AWS resources"
  type        = string
}
variable "aws_account_id" {
  description = "Your AWS account ID (12 digits UID)"
  type        = string
}
variable "aws_profile" {
  description = "AWS profile name to be used from shared credentials (~/.aws/credentials)"
  type        = string
}
variable "aws_region_container_registry_repository" {
  description = "Based on region: https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html"
  type        = string
}
variable "aws_eks_cluster_role_name" {
  description = "Role name to be created and used for EKS cluster"
  type        = string
  default     = "vYouEKSClusterRole"
}
variable "aws_eks_cluster_node_role_name" {
  description = "Role name to be created and used for EKS cluster nodes"
  type        = string
  default     = "vYouEKSClusterNodeRole"
}
variable "aws_eks_cluster_developer_access_role_name" {
  description = "Role name to be created and used for EKS cluster developer access"
  type        = string
  default     = "vYouEKSClusterDeveloperAccessRole"
}
variable "aws_eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "vyou-cluster"
}
variable "vyou_iss" {
  description = "VYou auth issuer URL"
  type        = string
}
variable "vyou_allowed_origins" {
  description = "VYou allowed origins"
  type        = string
}
variable "vyou_web_user" {
  description = "VYou web user"
  type        = string
}
variable "vyou_web_password" {
  description = "VYou web user password"
  type        = string
}
variable "vyou_migration_user" {
  description = "VYou migrations user"
  type        = string
}
variable "vyou_migration_password" {
  description = "VYou migrations user password"
  type        = string
}
variable "vyou_subdomain" {
  description = "VYou domain or subdomain"
  type        = string
}
variable "vyou_backend_version" {
  description = "VYou backend version"
  type        = string
}
variable "vyou_auth_server" {
  description = "VYou auth server URL"
  type        = string
}
variable "vyou_enable_alipay" {
  description = "VYou enable alipay (true/false)"
  type        = string
}
variable "vyou_sendgrid_key" {
  description = "VYou Sendgrid key"
  type        = string
}
variable "vyou_license_key" {
  description = "VYou license key"
  type        = string
}
variable "vyou_license_secret" {
  description = "VYou license secret"
  type        = string
}
variable "vyou_tenant_god_password" {
  description = "VYou backoffice admin password"
  type        = string
}
variable "vyou_tenant_god" {
  description = "VYou backoffice admin user email"
  type        = string
}
variable "vyou_stripe_hook_secret" {
  description = "VYou Stripe hook secret"
  type        = string
}
variable "vyou_db_version" {
  description = "VYou DB version"
  type        = string
}
variable "vyou_developer_user" {
  description = "VYou developer user"
  type        = string
}
variable "vyou_developer_password" {
  description = "VYou developer password"
  type        = string
}
variable "vyou_db_user" {
  description = "VYou DB user"
  type        = string
}
variable "vyou_db_password" {
  description = "VYou DB password"
  type        = string
}
variable "vyou_proxy_version" {
  description = "VYou proxy version"
  type        = string
}