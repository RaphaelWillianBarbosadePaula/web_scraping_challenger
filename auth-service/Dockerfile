FROM ruby:3.4

# Instala dependências do sistema
RUN apt-get update -qq && apt-get install -y postgresql-client build-essential libvips

# Define diretório de trabalho
WORKDIR /rails

# Variáveis de ambiente para produção/desenvolvimento
ENV RAILS_ENV=development
ENV BUNDLE_PATH=/usr/local/bundle

# Instala as gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copia o restante da aplicação
COPY . .

# Expõe a porta (será sobrescrita pelo compose, mas é boa prática)
EXPOSE 3000

# Script de entrada para corrigir PID do server
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Comando padrão
CMD ["rails", "server", "-b", "0.0.0.0"]