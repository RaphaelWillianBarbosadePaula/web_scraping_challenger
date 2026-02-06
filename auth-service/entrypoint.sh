#!/bin/bash
set -e

# Remove server.pid preexistente para o Rails não travar
rm -f /rails/tmp/pids/server.pid

# Executa o comando passado no CMD do Dockerfile
exec "$@"