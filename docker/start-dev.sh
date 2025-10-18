#!/bin/sh

# Aguardar um pouco para garantir que o sistema esteja pronto
sleep 2

# Verificar se o composer.json existe e instalar dependências
if [ -f "/var/www/composer.json" ]; then
    echo "Instalando dependências do Composer..."
    cd /var/www && composer install --optimize-autoloader
fi

# Verificar se o package.json existe e instalar dependências
if [ -f "/var/www/package.json" ]; then
    echo "Instalando dependências do NPM..."
    cd /var/www && npm install
fi

# Gerar chave da aplicação se não existir
if [ ! -f "/var/www/.env" ]; then
    echo "Copiando arquivo .env.example para .env..."
    cd /var/www && cp .env.example .env
fi

# Verificar se a chave da aplicação existe
cd /var/www
if ! grep -q "APP_KEY=base64:" .env; then
    echo "Gerando chave da aplicação..."
    php artisan key:generate --no-interaction
fi

# Criar banco SQLite se não existir
if [ ! -f "/var/www/database/database.sqlite" ]; then
    echo "Criando banco de dados SQLite..."
    mkdir -p /var/www/database
    touch /var/www/database/database.sqlite
fi

# Executar migrações
echo "Executando migrações..."
php artisan migrate --force --no-interaction

# Limpar e otimizar caches
echo "Limpando caches..."
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear

# Configurar permissões
echo "Configurando permissões..."
chmod -R 755 /var/www/storage
chmod -R 755 /var/www/bootstrap/cache

echo "Inicialização concluída! Iniciando serviços..."

# Iniciar supervisor
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
