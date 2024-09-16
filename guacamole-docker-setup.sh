#!/bin/bash

set -e

echo "Iniciando a configuração do ambiente Guacamole..."

# Clone do repositório, caso não esteja presente
if [ ! -d "guacamole-docker-setup" ]; then
  echo "Clonando o repositório..."
  git clone https://github.com/infiniteACodevops/guacamole-docker-setup.git
fi

cd guacamole-docker-setup

# Gerar script de inicialização do banco de dados
echo "Gerando script de inicialização do banco de dados..."
mkdir -p init-scripts
docker run --rm guacamole/guacamole:1.5.5 /opt/guacamole/bin/initdb.sh --mysql > init-scripts/initdb.sql

# Ajustar permissões dos arquivos
echo "Ajustando permissões dos arquivos..."
sudo chmod 755 init-scripts
sudo chmod 644 init-scripts/initdb.sql

# Criar configuração do Nginx
echo "Criando configuração do Nginx..."
mkdir -p nginx
cat <<EOT > nginx/nginx.conf
server {
    listen 80;
    server_name 192.168.51.125;

    location / {
        proxy_pass http://guacamole:8080/guacamole/;
        proxy_buffering off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header Host \$http_host;
    }
}
EOT

# Subir serviços
echo "Iniciando serviços..."
docker-compose up -d

echo "Configuração completa! Acesse o Guacamole em http://192.168.51.125/"
