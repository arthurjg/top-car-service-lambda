terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }

  # Backend remoto para armazenar o state de forma segura e compartilhada.
  # Crie o bucket S3 e a tabela DynamoDB de lock ANTES (veja terraform/bootstrap/).
  backend "s3" {
    bucket         = "SEU-BUCKET-TERRAFORM-STATE"     # ajuste
    key            = "lambda-cpf-token/terraform.tfstate"
    region         = "us-east-1"                       # ajuste
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
