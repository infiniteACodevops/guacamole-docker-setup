# Guacamole Docker Setup

Este repositório contém a configuração necessária para executar o Apache Guacamole com MariaDB usando Docker e Docker Compose.

## Configuração do Ambiente Guacamole

Para configurar o ambiente Guacamole, execute os seguintes comandos:

```bash
git clone https://github.com/infiniteACodevops/guacamole-docker-setup.git ~/guacamole-docker-setup && \
cd ~/guacamole-docker-setup && \
mkdir -p init-scripts && \
docker run --rm guacamole/guacamole:1.5.5 /opt/guacamole/bin/initdb.sh --mysql > init-scripts/initdb.sql && \
sudo chmod 755 init-scripts && \
sudo chmod 644 init-scripts/initdb.sql && \
cat <<EOT > /tmp/nginx.conf
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
mv /tmp/nginx.conf ./nginx.conf
docker-compose up -d
