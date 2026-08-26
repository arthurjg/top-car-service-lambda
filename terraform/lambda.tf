# Os arquivos .zip abaixo são gerados pelo pipeline do GitHub Actions
# ANTES de rodar o terraform apply (ver .github/workflows/deploy.yml):
#   ../build/lambda.zip -> código-fonte (lambda_function.py)
#   ../build/layer.zip  -> dependências (PyJWT), empacotadas como Lambda Layer

resource "aws_lambda_layer_version" "dependencies" {
  layer_name          = "${var.project_name}-${var.environment}-deps"
  filename            = "${path.module}/../build/layer.zip"
  source_code_hash    = filebase64sha256("${path.module}/../build/layer.zip")
  compatible_runtimes = [var.lambda_runtime]
}

resource "aws_lambda_function" "cpf_token" {
  function_name = "${var.project_name}-${var.environment}"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  filename         = "${path.module}/../build/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/../build/lambda.zip")

  layers = [aws_lambda_layer_version.dependencies.arn]

  environment {
    variables = {
      TABLE_NAME          = aws_dynamodb_table.clientes.name
      JWT_SECRET_ARN       = aws_secretsmanager_secret.jwt_secret.arn
      JWT_EXPIRATION_MIN  = tostring(var.jwt_expiration_minutes)
    }
  }

  tracing_config {
    mode = "Active" # habilita X-Ray para observabilidade
  }
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.cpf_token.function_name}"
  retention_in_days = 30
}
