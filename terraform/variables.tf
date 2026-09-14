variable "aws_region" {
  description = "Região da AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto, usado como prefixo dos recursos"
  type        = string
  default     = "lambda-cpf-token"
}

variable "environment" {
  description = "Ambiente de deploy (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "lambda_runtime" {
  description = "Runtime da Lambda"
  type        = string
  default     = "python3.12"
}

variable "lambda_timeout" {
  description = "Timeout da Lambda em segundos"
  type        = number
  default     = 10
}

variable "lambda_memory_size" {
  description = "Memória alocada para a Lambda (MB)"
  type        = number
  default     = 256
}

variable "jwt_expiration_minutes" {
  description = "Tempo de expiração do token JWT em minutos"
  type        = number
  default     = 30
}

variable "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB de clientes"
  type        = string
  default     = "clientes"
}
