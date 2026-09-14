# Tabela de clientes usada pela Lambda para consulta por CPF.
# Se a tabela já existir em produção, remova este recurso e use
# `terraform import` para trazer o recurso existente ao state.
resource "aws_dynamodb_table" "clientes" {
  name         = "${var.project_name}-${var.dynamodb_table_name}-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "cpf"

  attribute {
    name = "cpf"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }
}
