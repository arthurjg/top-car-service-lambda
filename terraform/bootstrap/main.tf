# ------------------------------------------------------------------------
# BOOTSTRAP — aplique isso UMA VEZ, manualmente (terraform apply local),
# antes do pipeline existir. Ele cria a "porta de entrada" que permite o
# GitHub Actions assumir uma role na AWS sem usar Access Keys fixas.
#
# Uso:
#   cd terraform/bootstrap
#   terraform init
#   terraform apply -var="github_org=SEU_ORG" -var="github_repo=SEU_REPO"
# ------------------------------------------------------------------------

terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "github_org" {
  description = "Organização/usuário do GitHub"
  type        = string
}

variable "github_repo" {
  description = "Nome do repositório"
  type        = string
}

# Provider OIDC do GitHub Actions (um por conta AWS, reutilizável entre repos)
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_actions_deploy" {
  name = "github-actions-${var.github_repo}-deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          # restringe a role à branch main deste repositório específico
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"
        }
      }
    }]
  })
}

# Em produção, troque por uma política mais restrita (least privilege)
# listando exatamente as ações/recursos necessários.
resource "aws_iam_role_policy_attachment" "deploy_admin" {
  role       = aws_iam_role.github_actions_deploy.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "deploy_role_arn" {
  value = aws_iam_role.github_actions_deploy.arn
}
