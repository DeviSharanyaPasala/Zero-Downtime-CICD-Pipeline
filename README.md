# Zero-Downtime-CICD

CI/CD pipeline that deploys a Flask app to AWS EKS with zero downtime.
Every push to main runs tests, builds a Docker image, pushes to ECR,
and deploys via Helm. Takes about 4 minutes end to end.

---

## Stack

- GitHub Actions
- Docker + ECR
- AWS EKS
- Helm
- Terraform

---

## How it works

```
push to main
    |
    ├── tests run
    ├── Docker image builds, pushes to ECR
    └── Helm deploys to EKS
            |
            ├── new pods spin up
            ├── /ready health check passes
            ├── traffic switches over
            └── old pods come down
```

If the deploy fails at any point, it rolls back automatically.

---

## Repo structure

```
zero-downtime-cicd/
├── app/
│   ├── app.py
│   └── requirements.txt
├── Dockerfile
├── helm/myapp/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── deployment.yaml
│       └── service.yaml
├── terraform/
│   ├── main.tf
│   ├── eks.tf
│   ├── variables.tf
│   └── outputs.tf
└── .github/workflows/
    └── deploy.yml
```

---

## Setup

### Prerequisites

- AWS account with CLI configured
- Terraform, kubectl, Helm installed

### 1. Provision infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Takes about 10-15 mins. Grab the outputs when done:

```bash
terraform output ecr_repository_url
terraform output eks_cluster_name
terraform output github_actions_access_key_id
terraform output github_actions_secret_access_key
```

### 2. Add GitHub secrets

Repo - Settings - Secrets and variables - Actions

| Secret | Value |
|---|---|
| `AWS_ACCESS_KEY_ID` | from terraform output |
| `AWS_SECRET_ACCESS_KEY` | from terraform output |
| `AWS_ECR_REPO` | from terraform output |
| `EKS_CLUSTER_NAME` | from terraform output |

### 3. Connect kubectl

```bash
aws eks update-kubeconfig --region us-east-1 --name zero-downtime-cicd-cluster
kubectl get nodes
```

### 4. Deploy

```bash
git add .
git commit -m "first deploy"
git push origin main
```

Check the Actions tab to watch it run.

### 5. Get the app URL

```bash
kubectl get svc myapp-service
```

---

## Rollback

```bash
helm rollback myapp
helm history myapp
helm rollback myapp 2
```

---

## Zero downtime explained

The `/ready` endpoint controls when traffic switches over. Kubernetes holds all traffic on the old pod until the new one hits `/ready` and returns 200. Combined with `maxUnavailable: 0`, the old pod never goes down before the new one is actually ready. Not just "probably fine" - actually ready.

---

## IAM note

Spent way too long on this. The GitHub Actions IAM user needs these two permissions:

```
eks:DescribeCluster
eks:ListClusters
```

Without them the deploy dies at the kubectl step with a generic auth error that doesn't tell you much. Already handled in `terraform/eks.tf` but if you fork this and something breaks, check there first.

---

## Cleanup

```bash
cd terraform
terraform destroy
```
