# Wiz Technical Exercise

## Architecture

- Node.js application in Docker
- Kubernetes (EKS)
- MongoDB on EC2 VM
- S3 bucket for backups
- Terraform Infrastructure as Code
- GitHub Actions pipelines

## Security Controls

- Checkov (IaC scanning)
- Gitleaks (secret detection)
- CloudTrail enabled

## Intentional Weaknesses

- Public SSH on Mongo VM
- AdministratorAccess IAM role
- Public S3 backup bucket
- Cluster-admin permissions for application
- Outdated MongoDB deployment

## Demo Plan

1. Show Terraform infrastructure
2. Show GitHub Actions pipelines
3. Show Kubernetes manifests
4. Demonstrate kubectl
5. Demonstrate application → MongoDB connectivity
6. Show security findings

## Local Run

```bash
cd app
npm install
docker build -t wiz-app .
docker run -p 3000:3000 wiz-app
```

Health check:

```bash
curl http://localhost:3000/health
```