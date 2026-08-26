"""
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
"""

import json
import os
import re
import logging
from datetime import datetime, timedelta, timezone
import jwt
import requests

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# ----------------------------------------------------------------------------
# Configurações
# ----------------------------------------------------------------------------
TOP_CAR_API_CLIENTES = os.environ.get("TOP_CAR_API_CLIENTES")
JWT_SECRET = os.environ.get("JWT_SECRET")  # em produção, buscar via Secrets Manager
JWT_EXPIRATION_MIN = int(os.environ.get("JWT_EXPIRATION_MIN", "30"))
JWT_ALGORITHM = "HS256"

# Status considerados válidos para liberar o token
STATUS_PERMITIDOS = {"ATIVO"}


# ----------------------------------------------------------------------------
# Utilidades
# ----------------------------------------------------------------------------
def limpar_cpf(cpf: str) -> str:
    """Remove qualquer caractere não numérico do CPF."""
    return re.sub(r"\D", "", cpf or "")


def validar_cpf(cpf: str) -> bool:
    """Valida o CPF verificando formato e dígitos verificadores."""
    cpf = limpar_cpf(cpf)

    if len(cpf) != 11 or cpf == cpf[0] * 11:
        return False

    def calcular_digito(cpf_parcial: str) -> int:
        soma = sum(
            int(digito) * peso
            for digito, peso in zip(cpf_parcial, range(len(cpf_parcial) + 1, 1, -1))
        )
        resto = (soma * 10) % 11
        return 0 if resto == 10 else resto

    digito1 = calcular_digito(cpf[:9])
    digito2 = calcular_digito(cpf[:9] + str(digito1))

    return cpf[-2:] == f"{digito1}{digito2}"


def extrair_cpf(event: dict) -> str:
    """Extrai o CPF do evento, seja de pathParameters, queryStringParameters ou body."""
    cpf = None

    if event.get("pathParameters"):
        cpf = event["pathParameters"].get("cpf")

    if not cpf and event.get("queryStringParameters"):
        cpf = event["queryStringParameters"].get("cpf")

    if not cpf and event.get("body"):
        try:
            body = json.loads(event["body"])
            cpf = body.get("cpf")
        except (json.JSONDecodeError, TypeError):
            pass

    return limpar_cpf(cpf) if cpf else None


def consultar_cliente(cpf: str) -> dict | None:
    """Consulta o cliente na API de clientes pelo CPF."""    
    response = requests.get(f"{TOP_CAR_API_CLIENTES}/{cpf}")

    if response.status_code == 200:
        dados = response.json()
        print(dados)
        return dados
    else:
        print(f"Erro: {response.status_code}")
        raise Exception(f"Erro ao consultar cliente: {response.status_code}")
    


def gerar_token(cliente: dict) -> str:
    """Gera o token JWT assinado com os dados do cliente."""
    agora = datetime.now(timezone.utc)
    payload = {
        "sub": cliente["cpf"],
        "nome": cliente.get("nome"),
        "status": cliente.get("status"),
        "iat": agora,
        "exp": agora + timedelta(minutes=JWT_EXPIRATION_MIN),
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)


def response(status_code: int, body: dict) -> dict:
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body, ensure_ascii=False),
    }


# ----------------------------------------------------------------------------
# Handler principal
# ----------------------------------------------------------------------------
def lambda_handler(event, context):
    try:
        cpf = extrair_cpf(event)

        if not cpf:
            return response(400, {"erro": "CPF não informado."})

        if not validar_cpf(cpf):
            return response(400, {"erro": "CPF inválido."})

        cliente = consultar_cliente(cpf)

        if not cliente:
            return response(404, {"erro": "Cliente não encontrado."})

        status = cliente.get("status")

        if status not in STATUS_PERMITIDOS:
            return response(
                403,
                {
                    "erro": "Cliente não autorizado.",
                    "status": status,
                },
            )

        if not JWT_SECRET:
            logger.error("JWT_SECRET não configurado.")
            return response(500, {"erro": "Erro interno de configuração."})

        token = gerar_token(cliente)

        return response(
            200,
            {
                "cpf": cliente["cpf"],
                "status": status,
                "token": token,
                "expira_em_minutos": JWT_EXPIRATION_MIN,
            },
        )

    except Exception:
        logger.exception("Erro ao processar requisição.")
        return response(500, {"erro": "Erro interno no processamento."})
