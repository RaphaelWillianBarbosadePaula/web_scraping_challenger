# Notification Service (Microsserviço de Notificações)

## Descrição e Responsabilidade
Microsserviço dedicado a centralizar o histórico de eventos do sistema. Ele recebe, valida e armazena notificações sobre o ciclo de vida das tarefas de scraping (criação, conclusão ou falha)

## Tecnologias e Requisitos
* **Linguagem:** Ruby 3.4
* **Framework:** Ruby on Rails (API Mode)
* **Banco de Dados:** PostgreSQL
* **Containerização:** Docker

## Instalação e Configuração
1.  Instale as gems: `bundle install`
2.  Configure o banco de dados.
3.  Execute: `rails db:migrate`

## Execução com Docker Compose
Este serviço é executado automaticamente pelo `docker-compose.yml` localizado no repositório do sistema principal.
Ele roda na porta **3002**.

## Variáveis de Ambiente
* `DB_HOST`, `DB_PASSWORD`: Credenciais do banco.

## Endpoints da API

### 1. Criar Notificação
* **URL:** `/notifications`
* **Método:** `POST`
* **Descrição:** Registra um novo evento do sistema.
* **Body:**
    ```json
    {
      "notification": {
        "event_type": "task_completed",
        "task_id": 123,
        "user_id": 45,
        "collected_data": "BMW X2 - R$ 250.000"
      }
    }
    ```
    *Campos obrigatórios: event_type, task_id, user_id*

### 2. Listar Notificações (Opcional)
* **URL:** `/notifications`
* **Método:** `GET`
* **Response:** Lista JSON das últimas notificações armazenadas.

## Testes
Para executar os testes:
```bash
docker-compose run --rm notification-service bundle exec rspec