# Top Car Service Lambda

![Amazon AWS Lambda](https://img.shields.io/badge/AWS%20Lambda-orange)
![Python](https://img.shields.io/badge/Python-3.13-purple)
![Terraform](https://img.shields.io/badge/Terraform-Enabled-purple)

## Técnologias

- **Python 3.13**
- **Git**
- **AWS Lambda**

## Propósito

lambda de segurança do app da officina

Lambda: consulta cliente por CPF e retorna JWT com o status do cliente.

Fluxo:
1. Recebe o CPF via path/query params ou body (JSON).
2. Valida o formato/dígitos verificadores do CPF.
3. Consulta o cliente na API de clientes (exemplo usando requests).
4. Verifica o status do cliente (ex: ATIVO, INATIVO, BLOQUEADO).
5. Gera um token JWT contendo os dados relevantes e retorna na resposta.

Variáveis de ambiente esperadas:
- TOP_CAR_API_CLIENTES -> URL da API de clientes (ex: "https://top-car-service-api.com/clientes")
- JWT_SECRET        -> segredo usado para assinar o token (idealmente vindo do Secrets Manager)
- JWT_EXPIRATION_MIN -> tempo de expiração do token em minutos (default: 30)

Dependências (requirements.txt):
    PyJWT==2.9.0
requests==2.31.0
    boto3 (já vem no runtime da Lambda, não precisa empacotar)

## Passos para execução e deploy

### 1.1. Execução Local

* Clone e Execução  do repositório:
```bash
git clone https://github.com/arthurjg/top-car-service-lambda
cd top-car-service-lambda
python lambda_function.py
```

### 1.2. Deploy

- commitar o código e fazer push na branch release/**

## Arquitetura

![arquitetura](/docs/arq-lambda-aws.drawio.png)
