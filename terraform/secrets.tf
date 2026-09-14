# Segredo usado para assinar o JWT.
# O valor do secret NÃO é gerenciado aqui de propósito — defina-o manualmente
# no console/CLI (ou via pipeline separado com acesso restrito) para não deixar
# segredos versionados no state do Terraform em texto plano.
resource "aws_secretsmanager_secret" "jwt_secret" {
  name        = "${var.project_name}-${var.environment}-jwt-secret"
  description = "Segredo usado para assinar os tokens JWT da função ${var.project_name}"
}

# Placeholder inicial — troque o valor manualmente após o primeiro apply:
# aws secretsmanager put-secret-value \
#   --secret-id "${var.project_name}-${var.environment}-jwt-secret" \
#   --secret-string "SEU_SEGREDO_FORTE_AQUI"
resource "aws_secretsmanager_secret_version" "jwt_secret_initial" {
  secret_id     = aws_secretsmanager_secret.jwt_secret.id
  secret_string = "CHANGE_ME"

  lifecycle {
    ignore_changes = [secret_string] # evita sobrescrever o valor real definido manualmente
  }
}
