output "ecr_repository_url" {
  description = "ECR URL — paste this into GitHub Actions secret AWS_ECR_REPO"
  value       = aws_ecr_repository.app.repository_url
}

output "eks_cluster_name" {
  description = "EKS cluster name — paste into GitHub Actions secret EKS_CLUSTER_NAME"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS API endpoint"
  value       = module.eks.cluster_endpoint
}

output "github_actions_access_key_id" {
  description = "AWS_ACCESS_KEY_ID — add this to GitHub Actions secrets"
  value       = aws_iam_access_key.github_actions.id
  sensitive   = true
}

output "github_actions_secret_access_key" {
  description = "AWS_SECRET_ACCESS_KEY — add this to GitHub Actions secrets"
  value       = aws_iam_access_key.github_actions.secret
  sensitive   = true
}
