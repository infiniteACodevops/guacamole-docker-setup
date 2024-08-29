# Guacamole Docker Setup

Este repositório contém a configuração necessária para executar o Guacamole usando Docker e Docker Compose.

## Comando Único para Configuração

Para configurar e iniciar o ambiente com um único comando, execute:

```bash
git clone https://github.com/infiniteACodevops/guacamole-docker-setup.git && \
cd guacamole-docker-setup && \
mkdir -p init-scripts && \
docker run --rm guacamole/guacamole:1.5.5 /opt/guacamole/bin/initdb.sh --mysql > init-scripts/initdb.sql && \
docker-compose up -d
