# Desafio Backend - Sistema de Web Scraping de Veículos

Este projeto consiste em uma solução baseada em **microsserviços** para coleta e gerenciamento de anúncios de veículos. A arquitetura foi desenhada para separar responsabilidades entre autenticação, notificação e o gerenciamento central de scraping, utilizando processamento assíncrono para as tarefas pesadas.

## 🏗 Arquitetura do Projeto

O sistema é composto por 3 serviços principais e infraestrutura de suporte, orquestrados via Docker Compose:

1.  **webscraping-manager (Porta 3000):**
    * Aplicação Fullstack (Rails + Views).
    * Responsável pela interface do usuário, gestão de tarefas e orquestração.
    * Possui um **Worker (Sidekiq)** dedicado para executar o scraping em background.
2.  **auth-service (Porta 3001):**
    * API Rails responsável por registro, login e emissão de tokens JWT.
3.  **notification-service (Porta 3002):**
    * API Rails responsável por armazenar o histórico de eventos e notificações do sistema.

### Infraestrutura
* **PostgreSQL:** Banco de dados compartilhado (com schemas/databases lógicos separados).
* **Redis:** Gerenciamento de filas para o Sidekiq.

---

## 🚀 Como Executar o Projeto

### Pré-requisitos
* Docker
* Docker Compose

### Passo a Passo

1.  **Clone o repositório:**
    ```bash
    git clone <URL_DO_SEU_REPOSITORIO>
    cd desafio-webscraping
    ```

2.  **Construa os containers:**
    ```bash
    docker-compose build
    ```

3.  **Configuração dos Bancos de Dados:**
    Antes de rodar pela primeira vez, é necessário criar os bancos e rodar as migrações para cada serviço. Execute os comandos abaixo na raiz do projeto:

    ```bash
    # Serviço de Autenticação
    docker-compose run --rm auth-service bin/rails db:create db:migrate

    # Serviço de Notificações
    docker-compose run --rm notification-service bin/rails db:create db:migrate

    # Gerenciador de Scraping (Principal)
    docker-compose run --rm webscraping-manager bin/rails db:create db:migrate
    ```

4.  **Subir a Aplicação:**
    ```bash
    docker-compose up
    ```

Acesse o sistema principal em: **[http://localhost:3000](http://localhost:3000)**

---

## 📂 Estrutura de Diretórios (Monorepo)

```text
.
├── auth-service/           # Código do microsserviço de autenticação
├── notification-service/   # Código do microsserviço de notificações
├── webscraping-manager/    # Código do sistema principal e workers
├── docker-compose.yml      # Orquestração de todo o ambiente
└── README.md               # Este arquivo