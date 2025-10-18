# CS2 PugSharp Manager - Docker Setup

Este projeto inclui configuração completa do Docker para desenvolvimento e produção.

## 🚀 Início Rápido

### Desenvolvimento

```bash
# Construir e iniciar o ambiente de desenvolvimento
make dev

# Ou usando docker-compose diretamente
docker-compose -f docker-compose.dev.yml up -d
```

A aplicação estará disponível em:
- **Aplicação**: http://localhost:8080
- **Vite Dev Server**: http://localhost:5173

### Produção

```bash
# Configurar variáveis de ambiente
cp .env.production.example .env.production
# Edite .env.production com suas configurações

# Construir e iniciar o ambiente de produção
make prod

# Ou usando docker-compose diretamente
docker-compose up -d
```

A aplicação estará disponível em: http://localhost

## 📦 Estrutura dos Containers

### Desenvolvimento (`docker-compose.dev.yml`)
- **nginx**: Servidor web (porta 8080)
- **app**: Aplicação Laravel + Vite dev server
- **queue**: Worker de filas (opcional)

### Produção (`docker-compose.yml`)
- **nginx**: Servidor web (porta 80/443)
- **app**: Aplicação Laravel
- **mysql**: Banco de dados MySQL
- **redis**: Cache e sessões
- **queue**: Worker de filas
- **scheduler**: Agendador de tarefas (cron)

## 🛠️ Comandos Disponíveis

### Comandos Básicos
```bash
make help              # Mostra todos os comandos disponíveis
make dev               # Inicia ambiente de desenvolvimento
make prod              # Inicia ambiente de produção
make down              # Para todos os containers
make logs              # Mostra logs do ambiente ativo
make shell             # Acessa shell do container
```

### Laravel/Artisan
```bash
make artisan cmd="migrate"           # Executa comando artisan
make migrate                         # Executa migrações
make seed                           # Executa seeders
make fresh                          # Reset completo do banco
make cache-clear                    # Limpa caches
```

### Composer e NPM
```bash
make composer cmd="install"         # Executa comando composer
make composer-install              # Instala dependências PHP
make npm cmd="install"             # Executa comando npm
make npm-build                     # Build de produção dos assets
```

### Testes
```bash
make test                          # Executa testes
make pest                          # Executa testes com Pest
```

### Limpeza
```bash
make clean                         # Remove containers e volumes não utilizados
make clean-all                     # Limpeza completa (CUIDADO!)
```

## 🔧 Configuração

### Desenvolvimento

O ambiente de desenvolvimento usa:
- SQLite como banco de dados
- Sistema de arquivos para cache e sessões
- Vite dev server para hot-reload dos assets
- Debug habilitado

### Produção

O ambiente de produção usa:
- MySQL como banco de dados
- Redis para cache e sessões
- Assets compilados e otimizados
- Debug desabilitado
- Logs de erro configurados

### Variáveis de Ambiente

#### Desenvolvimento
O ambiente de desenvolvimento usa as configurações padrão do Laravel com SQLite.

#### Produção
Copie e configure o arquivo `.env.production.example`:

```bash
cp .env.production.example .env.production
```

Principais configurações a serem ajustadas:
- `APP_KEY`: Chave da aplicação (será gerada automaticamente)
- `APP_URL`: URL da sua aplicação
- `DB_PASSWORD`: Senha do MySQL
- Configurações do Steam Auth (se usado)
- Configurações de email (se usado)

## 🔒 Segurança

### Produção
- Use senhas fortes para o banco de dados
- Configure SSL/HTTPS no Nginx
- Mantenha as imagens Docker atualizadas
- Configure backup regular do banco de dados

### Backup do Banco de Dados
```bash
# Fazer backup
make backup-db

# Restaurar backup
make restore-db file="backup_20241017_120000.sql"
```

## 🐛 Solução de Problemas

### Problemas Comuns

#### Permissões de arquivo
```bash
# Entrar no container e corrigir permissões
make shell
chmod -R 755 storage bootstrap/cache
```

#### Limpar caches
```bash
make cache-clear
```

#### Recriar containers
```bash
make down
make dev-build  # ou prod-build
```

#### Ver logs detalhados
```bash
make logs
# ou para um serviço específico
docker-compose -f docker-compose.dev.yml logs -f app
```

### Performance

#### Otimizar para produção
```bash
make optimize
```

#### Monitorar recursos
```bash
docker stats
```

## 📁 Estrutura de Arquivos Docker

```
docker/
├── nginx/
│   └── nginx.conf              # Configuração do Nginx
├── php-fpm.conf                # Configuração do PHP-FPM
├── supervisord.conf             # Supervisor para produção
├── supervisord.dev.conf         # Supervisor para desenvolvimento
└── start-dev.sh                 # Script de inicialização dev

Dockerfile                       # Dockerfile para produção
Dockerfile.dev                   # Dockerfile para desenvolvimento
docker-compose.yml               # Compose para produção
docker-compose.dev.yml           # Compose para desenvolvimento
.dockerignore                    # Arquivos ignorados no build
Makefile                         # Comandos facilitadores
```

## 🔄 Fluxo de Deploy

### Desenvolvimento
1. `make dev` - Inicia ambiente
2. Desenvolver normalmente
3. `make down` - Para ambiente

### Produção
1. Configurar `.env.production`
2. `make prod-build` - Build e deploy
3. `make migrate-prod` - Executar migrações
4. `make optimize` - Otimizar aplicação

## 📚 Recursos Adicionais

- [Documentação do Docker](https://docs.docker.com/)
- [Documentação do Laravel](https://laravel.com/docs)
- [Livewire Documentation](https://livewire.laravel.com/)

## 🆘 Suporte

Se encontrar problemas:
1. Verifique os logs: `make logs`
2. Consulte a seção de troubleshooting
3. Abra uma issue no repositório
