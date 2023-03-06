resource "aws_cloudformation_stack" "eks_cloudformation" {
  name = "${var.project_id}-vyou-cloudformation"

  template_url = "https://amazon-eks.s3.us-west-2.amazonaws.com/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml"

  tags = {
    project = var.project_id
  }
}
