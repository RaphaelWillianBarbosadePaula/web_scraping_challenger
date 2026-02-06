# Auth Service (Microsserviço de Autenticação)

## Descrição e Responsabilidade
Microsserviço responsável exclusivamente pelo gerenciamento de identidade. Ele lida com o registro de novos usuários, validação de credenciais (e-mail/senha) e emissão de tokens JWT (JSON Web Token) para sessões seguras.

## Tecnologias e Requisitos
* **Linguagem:** Ruby 3.4
* **Framework:** Ruby on Rails (API Mode)
* **Banco de Dados:** PostgreSQL
* **Autenticação:** JWT (JSON Web Token) & Bcrypt
* **Containerização:** Docker

## Instalação e Configuração
1.  Instale as gems: `bundle install`
2.  Configure o banco de dados.
3.  Execute: `rails db:migrate`

## Execução com Docker Compose
Este serviço é executado automaticamente pelo `docker-compose.yml` localizado no repositório do sistema principal.
Ele roda na porta **3001**.

## Variáveis de Ambiente
* `DB_HOST`, `DB_PASSWORD`: Credenciais do banco.
* `JWT_SECRET_KEY`: Chave secreta para assinatura dos tokens.

## Endpoints da API

### 1. Registrar Usuário
* **URL:** `/auth/register`
* **Método:** `POST`
* **Body:**
    ```json
    { "user": { "email": "teste@email.com", "password": "123" } }
    ```
* **Response:** `201 Created` com dados do usuário ou erros de validação.

### 2. Login
* **URL:** `/auth/login`
* **Método:** `POST`
* **Body:**
    ```json
    { "email": "teste@email.com", "password": "123" }
    ```
* **Response:** `200 OK`
    ```json
    { "token": "eyJhbGciOiJIUz...", "exp": "2024-12-31..." }
    ```
    Retorna o token JWT com data de expiração.

## Testes
Para executar os testes:
```bash
docker-compose run --rm auth-service bundle exec rspec