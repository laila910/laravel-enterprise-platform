# Laravel Docker Project Makefile
# Provides convenient shortcuts for common development tasks

.PHONY: help install start stop restart build shell artisan composer npm test format analyse quality fresh logs status cleanup

# Default target
.DEFAULT_GOAL := help

# Colors for output
GREEN := \033[32m
YELLOW := \033[33m
BLUE := \033[34m
RESET := \033[0m

# Docker Compose command detection
DOCKER_COMPOSE := $(shell which docker-compose 2>/dev/null)
ifndef DOCKER_COMPOSE
	DOCKER_COMPOSE := docker compose
endif

help: ## Show this help message
	@echo "$(BLUE)Laravel Docker Project$(RESET)"
	@echo ""
	@echo "$(YELLOW)Available commands:$(RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-15s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(YELLOW)Examples:$(RESET)"
	@echo "  make install          # Initialize the project"
	@echo "  make start            # Start all containers"
	@echo "  make artisan cmd=migrate # Run artisan migrate"
	@echo "  make composer cmd='require vendor/package' # Install package"
	@echo ""

install: ## Initialize the project (first time setup)
	@echo "$(BLUE)Initializing Laravel Docker Project...$(RESET)"
	@chmod +x scripts/init.sh
	@./scripts/init.sh

start: ## Start all containers
	@echo "$(BLUE)Starting containers...$(RESET)"
	@$(DOCKER_COMPOSE) up -d

stop: ## Stop all containers
	@echo "$(BLUE)Stopping containers...$(RESET)"
	@$(DOCKER_COMPOSE) down

restart: ## Restart all containers
	@echo "$(BLUE)Restarting containers...$(RESET)"
	@$(DOCKER_COMPOSE) restart

build: ## Build containers
	@echo "$(BLUE)Building containers...$(RESET)"
	@$(DOCKER_COMPOSE) build --no-cache

shell: ## Access application shell
	@$(DOCKER_COMPOSE) exec app bash

artisan: ## Run artisan command (usage: make artisan cmd="migrate")
	@$(DOCKER_COMPOSE) exec app php artisan $(cmd)

composer: ## Run composer command (usage: make composer cmd="install")
	@$(DOCKER_COMPOSE) exec app composer $(cmd)

npm: ## Run npm command (usage: make npm cmd="install")
	@$(DOCKER_COMPOSE) run --rm node npm $(cmd)

test: ## Run PHPUnit tests
	@echo "$(BLUE)Running tests...$(RESET)"
	@$(DOCKER_COMPOSE) exec app php artisan test

test-coverage: ## Run tests with coverage
	@echo "$(BLUE)Running tests with coverage...$(RESET)"
	@$(DOCKER_COMPOSE) exec app php artisan test --coverage

format: ## Format code using PHP CS Fixer
	@echo "$(BLUE)Formatting code...$(RESET)"
	@$(DOCKER_COMPOSE) exec app ./vendor/bin/php-cs-fixer fix --verbose

lint: ## Lint code using PHPCS
	@echo "$(BLUE)Linting code...$(RESET)"
	@$(DOCKER_COMPOSE) exec app ./vendor/bin/phpcs

analyse: ## Run static analysis with PHPStan
	@echo "$(BLUE)Running static analysis...$(RESET)"
	@$(DOCKER_COMPOSE) exec app ./vendor/bin/phpstan analyse

quality: ## Run all quality checks (lint, analyse, test)
	@echo "$(BLUE)Running quality checks...$(RESET)"
	@$(DOCKER_COMPOSE) exec app ./vendor/bin/phpcs || true
	@$(DOCKER_COMPOSE) exec app ./vendor/bin/phpstan analyse || true
	@$(DOCKER_COMPOSE) exec app php artisan test || true

migrate: ## Run database migrations
	@echo "$(BLUE)Running migrations...$(RESET)"
	@$(DOCKER_COMPOSE) exec app php artisan migrate

migrate-fresh: ## Fresh migrate with seeding
	@echo "$(BLUE)Fresh migration with seeding...$(RESET)"
	@$(DOCKER_COMPOSE) exec app php artisan migrate:fresh --seed

seed: ## Run database seeders
	@echo "$(BLUE)Running seeders...$(RESET)"
	@$(DOCKER_COMPOSE) exec app php artisan db:seed

cache-clear: ## Clear all caches
	@echo "$(BLUE)Clearing caches...$(RESET)"
	@$(DOCKER_COMPOSE) exec app php artisan cache:clear
	@$(DOCKER_COMPOSE) exec app php artisan config:clear
	@$(DOCKER_COMPOSE) exec app php artisan route:clear
	@$(DOCKER_COMPOSE) exec app php artisan view:clear

cache-warm: ## Warm up caches
	@echo "$(BLUE)Warming up caches...$(RESET)"
	@$(DOCKER_COMPOSE) exec app php artisan config:cache
	@$(DOCKER_COMPOSE) exec app php artisan route:cache
	@$(DOCKER_COMPOSE) exec app php artisan view:cache

fresh: ## Fresh start (rebuild and restart everything)
	@echo "$(BLUE)Fresh start...$(RESET)"
	@$(DOCKER_COMPOSE) down -v
	@docker rmi $$(docker images -q -f "reference=*laravel*") 2>/dev/null || true
	@$(DOCKER_COMPOSE) up --build -d
	@$(DOCKER_COMPOSE) exec app composer install
	@$(DOCKER_COMPOSE) exec app php artisan key:generate
	@$(DOCKER_COMPOSE) exec app php artisan migrate --force

logs: ## Show application logs
	@$(DOCKER_COMPOSE) logs -f app

status: ## Show container status
	@$(DOCKER_COMPOSE) ps

cleanup: ## Clean up Docker resources
	@echo "$(BLUE)Cleaning up Docker resources...$(RESET)"
	@$(DOCKER_COMPOSE) down -v
	@docker system prune -f
	@docker volume prune -f

# Development shortcuts
dev-start: start ## Alias for start
dev-stop: stop ## Alias for stop
dev-restart: restart ## Alias for restart

# Production helpers
prod-build: ## Build for production
	@echo "$(BLUE)Building for production...$(RESET)"
	@$(DOCKER_COMPOSE) -f docker-compose.yml build --target production

prod-deploy: ## Deploy to production
	@echo "$(BLUE)Deploying to production...$(RESET)"
	@$(DOCKER_COMPOSE) -f docker-compose.yml --profile production up -d
