# Web Scraping Manager (Sistema Principal)

## Descrição e Responsabilidade
Este é o serviço central do sistema de coleta de anúncios. Ele atua como o orquestrador, sendo responsável por fornecer a interface de usuário (UI) para gerenciamento de tarefas, comunicar-se com os microsserviços de Autenticação e Notificações, e despachar jobs de scraping para processamento assíncrono.

## Tecnologias e Requisitos
*Linguagem:** Ruby 3.4
**Framework:** Ruby on Rails 8.x
**Banco de Dados:** PostgreSQL
**Processamento Assíncrono:** Sidekiq & Redis
**Scraping:** Nokogiri
**Containerização:** Docker & Docker Compose

## Instalação e Configuração
Para rodar este projeto individualmente (modo desenvolvimento local):

1.  Instale as dependências: `bundle install`
2.  Configure o banco de dados em `config/database.yml`.
3.  Execute as migrações: `rails db:migrate`

## Execução com Docker Compose
Conforme solicitado, este repositório contém o arquivo `docker-compose.yml` que orquestra todo o ecossistema (Manager, Auth, Notification, Redis e DB).

Para subir todo o ambiente:
```bash
docker-compose up --build