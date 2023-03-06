# VYou AWS EKS Terraform

This Terraform configuration setups all resources needed to create an AWS EKS cluster to run VYou. It also installs needed packages to be able to use Kubernetes ALB Controller.

## Requirements

- Terraform
- AWS CLI
- AWS Account & credentials

# Setup

- Add your domain SSL certificates and keys to `./cert.pem` (domain certificate), `./chain.pem` (chain certificate), `./fullchain.pem` (full chain certificate) and `./key.pem` (private key).
- Copy `./templates/nginx.json.template` into `./nginx.json` and fill all required data.

## Deployment

- Copy `backend.config.template` in `backend.config` and fill all required data to be used to store your Terraform state and config in S3.
- Create a `project.tfvars` and fill all required variables based on `variables.tf`. Pay special attention to specified naming requirements to avoid problems during deployment.
- Run `./apply.sh` to initialize Terraform (it's not mandatory to run `./init.sh`) and plan or apply the release to AWS.
- A new Application Load Balancer will be created for the proxy service. You should point your (sub)domain DNS to the ALB public address. You can use Route 53 as your DNS and create an A - Alias record to point to the ALB or create a CNAME record in your DNS provider.

## Granting access to other users

- Ensure your AWS IAM user is [configured](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_permissions-to-switch.html) to switch roles
- Log in with your dev AWS IAM user and switch to the dev access role (it's created for you based in the name your provided in your project.tfvars file) in [console](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-console.html) or [cli](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-cli.html)

## Setup Kubectl to access your cluster

- Run `aws eks update-kubeconfig --profile YOUR_AWS_PROFILE --region YOUR_AWS_REGION --name YOUR_CLUSTER_NAME` to update create a new kubectl context so you can [connect to the remote cluster](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html#eks-configure-kubectl)
