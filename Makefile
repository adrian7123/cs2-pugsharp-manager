# CS2 PugSharp Manager - Docker Commands

.PHONY: help build up down dev prod logs shell composer artisan npm test clean

# Variáveis
COMPOSE_FILE_DEV=docker-compose.dev.yml
COMPOSE_FILE_PROD=docker-compose.yml
APP_CONTAINER_DEV=cs2-pugsharp-app-dev
APP_CONTAINER_PROD=cs2-pugsharp-app

# Comando padrão
help: ## Mostra esta mensagem de ajuda
	@echo "CS2 PugSharp Manager - Comandos Docker disponíveis:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Comandos de Build
build: ## Constrói as imagens Docker
	docker-compose -f $(COMPOSE_FILE_DEV) build --no-cache

build-prod: ## Constrói as imagens Docker para produção
	docker-compose -f $(COMPOSE_FILE_PROD) build --no-cache

# Comandos de Desenvolvimento
dev: ## Inicia o ambiente de desenvolvimento
	docker-compose -f $(COMPOSE_FILE_DEV) up -d
	@echo "Aplicação disponível em: http://localhost:8080"
	@echo "Vite dev server em: http://localhost:5173"

dev-build: ## Reconstrói e inicia o ambiente de desenvolvimento
	docker-compose -f $(COMPOSE_FILE_DEV) up -d --build

dev-logs: ## Mostra logs do ambiente de desenvolvimento
	docker-compose -f $(COMPOSE_FILE_DEV) logs -f

dev-down: ## Para o ambiente de desenvolvimento
	docker-compose -f $(COMPOSE_FILE_DEV) down

# Comandos de Produção
prod: ## Inicia o ambiente de produção
	docker-compose -f $(COMPOSE_FILE_PROD) up -d
	@echo "Aplicação disponível em: http://localhost"

prod-build: ## Reconstrói e inicia o ambiente de produção
	docker-compose -f $(COMPOSE_FILE_PROD) up -d --build

prod-logs: ## Mostra logs do ambiente de produção
	docker-compose -f $(COMPOSE_FILE_PROD) logs -f

prod-down: ## Para o ambiente de produção
	docker-compose -f $(COMPOSE_FILE_PROD) down

# Comandos Gerais
up: dev ## Alias para 'dev'

down: ## Para todos os containers
	docker-compose -f $(COMPOSE_FILE_DEV) down 2>/dev/null || true
	docker-compose -f $(COMPOSE_FILE_PROD) down 2>/dev/null || true

logs: dev-logs ## Alias para 'dev-logs'

# Comandos de Shell e Execução
shell: ## Acessa o shell do container da aplicação (dev)
	docker exec -it $(APP_CONTAINER_DEV) sh

shell-prod: ## Acessa o shell do container da aplicação (prod)
	docker exec -it $(APP_CONTAINER_PROD) sh

# Comandos Laravel
artisan: ## Executa comandos Artisan (uso: make artisan cmd="migrate")
	docker exec -it $(APP_CONTAINER_DEV) php artisan $(cmd)

artisan-prod: ## Executa comandos Artisan em produção
	docker exec -it $(APP_CONTAINER_PROD) php artisan $(cmd)

migrate: ## Executa migrações
	docker exec -it $(APP_CONTAINER_DEV) php artisan migrate

migrate-prod: ## Executa migrações em produção
	docker exec -it $(APP_CONTAINER_PROD) php artisan migrate --force

seed: ## Executa seeders
	docker exec -it $(APP_CONTAINER_DEV) php artisan db:seed

fresh: ## Reset completo do banco (migrate:fresh + seed)
	docker exec -it $(APP_CONTAINER_DEV) php artisan migrate:fresh --seed

# Comandos Composer
composer: ## Executa comandos Composer (uso: make composer cmd="install")
	docker exec -it $(APP_CONTAINER_DEV) composer $(cmd)

composer-install: ## Instala dependências do Composer
	docker exec -it $(APP_CONTAINER_DEV) composer install

composer-update: ## Atualiza dependências do Composer
	docker exec -it $(APP_CONTAINER_DEV) composer update

# Comandos NPM
npm: ## Executa comandos NPM (uso: make npm cmd="install")
	docker exec -it $(APP_CONTAINER_DEV) npm $(cmd)

npm-install: ## Instala dependências do NPM
	docker exec -it $(APP_CONTAINER_DEV) npm install

npm-dev: ## Executa build de desenvolvimento do Vite
	docker exec -it $(APP_CONTAINER_DEV) npm run dev

npm-build: ## Executa build de produção do Vite
	docker exec -it $(APP_CONTAINER_DEV) npm run build

# Comandos de Teste
test: ## Executa os testes
	docker exec -it $(APP_CONTAINER_DEV) php artisan test

pest: ## Executa testes com Pest
	docker exec -it $(APP_CONTAINER_DEV) ./vendor/bin/pest

# Comandos de Limpeza
clean: ## Remove containers, volumes e imagens não utilizadas
	docker-compose -f $(COMPOSE_FILE_DEV) down -v --remove-orphans
	docker-compose -f $(COMPOSE_FILE_PROD) down -v --remove-orphans
	docker system prune -f

clean-all: ## Limpeza completa (CUIDADO: remove TODOS os dados)
	docker-compose -f $(COMPOSE_FILE_DEV) down -v --remove-orphans
	docker-compose -f $(COMPOSE_FILE_PROD) down -v --remove-orphans
	docker system prune -af --volumes

# Comandos de Cache
cache-clear: ## Limpa todos os caches Laravel
	docker exec -it $(APP_CONTAINER_DEV) php artisan config:clear
	docker exec -it $(APP_CONTAINER_DEV) php artisan route:clear
	docker exec -it $(APP_CONTAINER_DEV) php artisan view:clear
	docker exec -it $(APP_CONTAINER_DEV) php artisan cache:clear

optimize: ## Otimiza a aplicação para produção
	docker exec -it $(APP_CONTAINER_PROD) php artisan config:cache
	docker exec -it $(APP_CONTAINER_PROD) php artisan route:cache
	docker exec -it $(APP_CONTAINER_PROD) php artisan view:cache

# Comandos de Backup (apenas produção)
backup-db: ## Faz backup do banco MySQL
	docker exec cs2-pugsharp-mysql mysqldump -u root -psecret cs2_pugsharp > backup_$(shell date +%Y%m%d_%H%M%S).sql

restore-db: ## Restaura backup do banco (uso: make restore-db file="backup.sql")
	docker exec -i cs2-pugsharp-mysql mysql -u root -psecret cs2_pugsharp < $(file)

# Status
status: ## Mostra status dos containers
	docker-compose -f $(COMPOSE_FILE_DEV) ps 2>/dev/null || echo "Dev environment not running"
	docker-compose -f $(COMPOSE_FILE_PROD) ps 2>/dev/null || echo "Prod environment not running"
