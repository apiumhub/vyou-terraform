provider "kubectl" {
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
  load_config_file       = "false"
}

data "http" "wait_for_cluster" {
  ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  timeout        = 300
  url            = format("%s/healthz", aws_eks_cluster.eks_cluster.endpoint)
}

resource "kubectl_manifest" "aws_auth" {
  yaml_body = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app.kubernetes.io/managed-by: Terraform
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |  
    - rolearn: ${aws_iam_role.cluster_node_role.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: ${aws_iam_role.cluster_developer_access_role.arn}
      username: vyou-admin
      groups:
        - system:masters
YAML

  depends_on = [aws_eks_cluster.eks_cluster, aws_eks_node_group.eks_cluster_node_group]
}
