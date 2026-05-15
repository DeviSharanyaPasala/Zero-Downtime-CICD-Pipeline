# ──────────────────────────────────────────────
# EKS Cluster
# ──────────────────────────────────────────────
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = "${var.project_name}-cluster"
  cluster_version = "1.32"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true   # Allows kubectl from your machine

  # Managed node group — AWS handles the EC2 instances for you
  eks_managed_node_groups = {
    default = {
      name           = "default-node-group"
      instance_types = ["t3.micro"]   # 2 vCPU, 4GB RAM — good for dev/demo

      min_size     = 1
      max_size     = 3
      desired_size = 2

      # Nodes run in private subnets — only accessible via load balancer
      subnet_ids = module.vpc.private_subnets

      labels = {
        Environment = "production"
        Project     = var.project_name
      }

      tags = var.common_tags
    }
  }

  tags = var.common_tags
}

# ──────────────────────────────────────────────
# IAM — GitHub Actions needs permission to push
# to ECR and deploy to EKS
# ──────────────────────────────────────────────
resource "aws_iam_user" "github_actions" {
  name = "${var.project_name}-github-actions"
  tags = var.common_tags
}

resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}

resource "aws_iam_user_policy" "github_actions" {
  name = "${var.project_name}-github-actions-policy"
  user = aws_iam_user.github_actions.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Push/pull Docker images to ECR
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      },
      {
        # Deploy to EKS
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      }
    ]
  })
}
