# EKS cluster role

resource "aws_iam_role" "cluster_role" {
  name = var.aws_eks_cluster_role_name

  assume_role_policy = file("${path.module}/policies/cluster-role-trust-policy.json")

  tags = {
    project = var.project_id
  }
}

resource "aws_iam_role_policy_attachment" "cluster_role_eks_policy_attachment" {
  role       = aws_iam_role.cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS cluster nodes role

resource "aws_iam_role" "cluster_node_role" {
  name = var.aws_eks_cluster_node_role_name

  assume_role_policy = file("${path.module}/policies/node-role-trust-policy.json")

  tags = {
    project = var.project_id
  }
}

resource "aws_iam_role_policy_attachment" "cluster_node_role_eksworker_policy_attachment" {
  role       = aws_iam_role.cluster_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cluster_node_role_ec2cr_policy_attachment" {
  role       = aws_iam_role.cluster_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "cluster_node_role_ekscni_attachment" {
  role       = aws_iam_role.cluster_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_policy" "node_alb_policy" {
  name        = "vyou-node-alb-policy"
  description = "VYou EKS node policy for the ALB Ingress"

  policy = file("${path.module}/policies/node-role-alb-policy.json")
}

resource "aws_iam_role_policy_attachment" "cluster_node_role_alb_attachment" {
  role       = aws_iam_role.cluster_node_role.name
  policy_arn = aws_iam_policy.node_alb_policy.arn
}

# EKS developers access role

resource "aws_iam_role" "cluster_developer_access_role" {
  name = var.aws_eks_cluster_developer_access_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "${var.aws_account_id}"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  inline_policy {
    name = "vyou_eks_cluster_developer_access"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["eks:*"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

  tags = {
    project = var.project_id
  }
}
