resource "aws_eks_cluster" "eks_cluster" {
  name     = var.aws_eks_cluster_name
  version  = "1.25"
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    endpoint_public_access = true
    endpoint_private_access = true
    #vpc_id = "${aws_cloudformation_stack.eks_cloudformation.outputs["VpcId"]}"
    subnet_ids = split(",", aws_cloudformation_stack.eks_cloudformation.outputs["SubnetIds"])
    security_group_ids = split(",", aws_cloudformation_stack.eks_cloudformation.outputs["SecurityGroups"])
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role.cluster_role,
    aws_iam_role_policy_attachment.cluster_role_eks_policy_attachment
  ]

  tags = {
    project = var.project_id
  }
}

resource "aws_eks_node_group" "eks_cluster_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "vyou"
  node_role_arn   = aws_iam_role.cluster_node_role.arn
  subnet_ids = split(",", aws_cloudformation_stack.eks_cloudformation.outputs["SubnetIds"])

  ami_type = "AL2_x86_64"
  capacity_type  = "ON_DEMAND"
  # In GiB
  disk_size = 100
  instance_types = ["t3.large"]

  scaling_config {
    desired_size = 1
    max_size     = 4
    min_size     = 1
  }

  update_config {
    max_unavailable_percentage = 50
  }

  tags = {
    project = var.project_id
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role.cluster_node_role,
    aws_iam_role_policy_attachment.cluster_node_role_eksworker_policy_attachment,
    aws_iam_role_policy_attachment.cluster_node_role_ec2cr_policy_attachment,
    aws_iam_role_policy_attachment.cluster_node_role_ekscni_attachment
  ]
}

# Install ALB Controller through Helm

data "aws_eks_cluster" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.name
}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.name
}

provider "helm" {
  version = "2.4.1"
  kubernetes {
    host                   = data.aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.eks_cluster.token
  }
}

# Workaround: tmp delay for ALB deletion to be triggered
resource "time_sleep" "alb_deletion_trigger" {
  depends_on = [
    aws_eks_cluster.eks_cluster, 
    aws_eks_node_group.eks_cluster_node_group
  ]

  destroy_duration = "120s"
}

resource "helm_release" "lb_controller" {
  depends_on = [time_sleep.alb_deletion_trigger]
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  version    = "1.4.0"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = data.aws_eks_cluster.eks_cluster.name
  }
}

resource "helm_release" "backube_snapscheduler" {
  depends_on = [aws_eks_cluster.eks_cluster, aws_eks_node_group.eks_cluster_node_group]
  name       = "backube-snapscheduler"
  chart      = "snapscheduler"
  repository = "https://backube.github.io/helm-charts"
  version    = "3.2.0"
  namespace  = "default"
}
