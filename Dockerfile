FROM php:8.2-fpm-alpine

# Instalar dependências do sistema
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    sqlite \
    sqlite-dev \
    nodejs \
    npm \
    supervisor

# Limpar cache
RUN apk del --no-cache \
    libpng-dev \
    libonig-dev \
    libxml2-dev

# Instalar extensões do PHP
RUN docker-php-ext-install \
    pdo_sqlite \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    opcache

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Criar usuário para a aplicação Laravel
RUN addgroup -g 1000 www && \
    adduser -u 1000 -G www -s /bin/sh -D www

# Definir diretório de trabalho
WORKDIR /var/www

# Copiar arquivos de dependências primeiro (para melhor cache do Docker)
COPY --chown=www:www composer.json composer.lock ./
COPY --chown=www:www package.json package-lock.json* ./

# Instalar dependências do PHP
USER www
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

# Instalar dependências do Node.js
RUN npm ci --only=production

# Copiar o resto da aplicação
USER root
COPY --chown=www:www . .

# Finalizar instalação do Composer
USER www
RUN composer dump-autoload --optimize

# Build dos assets
RUN npm run build

# Configurar permissões
USER root
RUN chown -R www:www /var/www && \
    chmod -R 755 /var/www/storage && \
    chmod -R 755 /var/www/bootstrap/cache

# Configuração do Supervisor
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Configuração do PHP-FPM
COPY docker/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf

# Expor porta 9000 para PHP-FPM
EXPOSE 9000

# Mudar para usuário www
USER www

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]