# top-car-service-lambda
lambda de segurança do app da officina

Lambda: consulta cliente por CPF e retorna JWT com o status do cliente.

Fluxo:
1. Recebe o CPF via path/query params ou body (JSON).
2. Valida o formato/dígitos verificadores do CPF.
3. Consulta o cliente na API de clientes (exemplo usando requests).
4. Verifica o status do cliente (ex: ATIVO, INATIVO, BLOQUEADO).
5. Gera um token JWT contendo os dados relevantes e retorna na resposta.

Variáveis de ambiente esperadas:
- TOP_CAR_API_CLIENTES -> URL da API de clientes (ex: "https://api.exemplo.com/clientes")
- JWT_SECRET        -> segredo usado para assinar o token (idealmente vindo do Secrets Manager)
- JWT_EXPIRATION_MIN -> tempo de expiração do token em minutos (default: 30)

Dependências (requirements.txt):
    PyJWT==2.9.0
requests==2.31.0
    boto3 (já vem no runtime da Lambda, não precisa empacotar)
