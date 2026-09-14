output "lambda_function_name" {
  value = aws_lambda_function.cpf_token.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.cpf_token.arn
}

output "api_endpoint" {
  description = "URL base da API. Chame: {api_endpoint}/clientes/{cpf}/token"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.clientes.name
}

output "jwt_secret_arn" {
  value = aws_secretsmanager_secret.jwt_secret.arn
}
