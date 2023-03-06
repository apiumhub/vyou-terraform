# External snapshotter

locals {

  csi-external-snapshotter = {
    enabled = true
    version = "v6.2.1"
  }

  csi-external-snapshotter_yaml_files = [
    "https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${local.csi-external-snapshotter.version}/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml",
    "https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${local.csi-external-snapshotter.version}/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml",
    "https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${local.csi-external-snapshotter.version}/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml",
    "https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${local.csi-external-snapshotter.version}/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml",
    "https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${local.csi-external-snapshotter.version}/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml"
  ]

  csi-external-snapshotter_apply = local.csi-external-snapshotter["enabled"] ? [for v in data.kubectl_file_documents.csi-external-snapshotter[0].documents : {
    data : yamldecode(v)
    content : v
    }
  ] : null

}

data "http" "csi-external-snapshotter" {
  provider = http-hashicorp
  for_each = local.csi-external-snapshotter.enabled ? toset(local.csi-external-snapshotter_yaml_files) : []
  url      = each.key
}

data "kubectl_file_documents" "csi-external-snapshotter" {
  count   = local.csi-external-snapshotter.enabled ? 1 : 0
  content = join("\n---\n", [for k, v in data.http.csi-external-snapshotter : v.response_body])
}

resource "kubectl_manifest" "csi-external-snapshotter" {
  depends_on = [aws_eks_cluster.eks_cluster, aws_eks_node_group.eks_cluster_node_group]
  for_each  = local.csi-external-snapshotter.enabled ? { for v in local.csi-external-snapshotter_apply : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content } : {}
  yaml_body = each.value
}

# EKS EBS CSI addon

variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))

  default = [
    {
      name    = "aws-ebs-csi-driver"
      version = "v1.15.0-eksbuild.1"
    }
  ]
}

data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${aws_eks_cluster.eks_cluster.name}"
  provider_url                  = replace(aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer, "https://", "")
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

resource "aws_eks_addon" "addons" {
  depends_on = [
    aws_eks_cluster.eks_cluster, 
    aws_eks_node_group.eks_cluster_node_group, 
    module.irsa-ebs-csi,
    kubectl_manifest.csi-external-snapshotter
  ]
  for_each          = { for addon in var.addons : addon.name => addon }
  cluster_name      = aws_eks_cluster.eks_cluster.name
  addon_name        = each.value.name
  addon_version     = each.value.version
  resolve_conflicts = "OVERWRITE"
  service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
  tags = {
    project = var.project_id
  }
}