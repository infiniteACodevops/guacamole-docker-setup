#!/bin/bash

set -e

# Diretório onde o repositório será clonado
REPO_DIR=~/guacamole-docker-setup

# Verificar se o repositório já existe
if [ ! -d "$REPO_DIR" ]; then
  echo "Clonando o repositório..."
  git clone https://github.com/infiniteACodevops/guacamole-docker-setup.git "$REPO_DIR"
fi

echo "Entrando no diretório do projeto..."
cd "$REPO_DIR"

echo "Criando diretório init-scripts..."
mkdir -p init-scripts

echo "Gerando o script de inicialização do banco de dados..."
docker run --rm guacamole/guacamole:1.5.5 /opt/guacamole/bin/initdb.sh --mysql > init-scripts/initdb.sql

echo "Ajustando permissões..."
sudo chmod 755 init-scripts
sudo chmod 644 init-scripts/initdb.sql

echo "Criando a configuração do Nginx..."
cat <<EOT > ./nginx.conf
server {
    listen 80;

    location / {
        set_real_ip_from 0.0.0.0/0;
        real_ip_header CF-Connecting-IP;
        real_ip_recursive on;

        proxy_pass http://guacamole:8080/guacamole/;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-Hostname \$http_host;
    }
}
EOT

echo "Subindo os serviços..."
docker-compose up -d
