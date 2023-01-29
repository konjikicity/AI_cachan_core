#!make
DOCKER_COMPOSER_PATH=laradock/docker-compose.yml
AI_CACHAN_PATH=/var/www/AI_cachan
AI_CACHAN_ADMIN_PATH=/var/www/AI_cachan_admin

-include .env
export
DC=docker-compose
STAGE=local
GIT=git pull origin
all: ## All
build: ## Build
	@$(DC) -f $(DOCKER_COMPOSER_PATH) build nginx mysql phpmyadmin redis workspace minio mailhog
up: ## Docker UP
	@$(DC) -f $(DOCKER_COMPOSER_PATH) up -d nginx mysql phpmyadmin redis workspace minio mailhog
down: ## Docker Down
	@$(DC) -f $(DOCKER_COMPOSER_PATH) down
restart: ## Docker Restart
	@$(DC) -f $(DOCKER_COMPOSER_PATH) restart
reload: ## Docker Reload
	@$(DC) -f $(DOCKER_COMPOSER_PATH) down
	@$(DC) -f $(DOCKER_COMPOSER_PATH) up -d nginx mysql phpmyadmin redis workspace minio mailhog
ps: ## Docker ps
	@$(DC) -f $(DOCKER_COMPOSER_PATH) ps
exec: ## Docker Exec | args NAME
	@$(DC) -f $(DOCKER_COMPOSER_PATH) exec workspace bash
clean: ## Docker Clean !!手持ちのイメージ、ボリュームがすべて消えます。!!
	@docker image prune
	@docker volume prune


# Composer Command
composer:
	@$(DC) -f $(DOCKER_COMPOSER_PATH) exec workspace /bin/bash -c "cd $(AI_CACHAN_PATH) && composer $(C)"

# Composer Command For Admin
composer_admin:
	@$(DC) -f $(DOCKER_COMPOSER_PATH) exec workspace /bin/bash -c "cd $(AI_CACHAN_ADMIN_PATH) && composer $(C)"

# Artisan Command
artisan_:
	@$(DC) -f $(DOCKER_COMPOSER_PATH) exec workspace /bin/bash -c "cd $(AI_CACHAN_PATH) && php artisan $(C)"

# Artisan Command For Admin
artisan_admin_:
	@$(DC) -f $(DOCKER_COMPOSER_PATH) exec workspace /bin/bash -c "cd $(AI_CACHAN_ADMIN_PATH) && php artisan $(C)"

setting_file:
	@cp laradock/.env.example laradock/.env
	@cp AI_cachan/.env.example AI_cachan/.env
	@cp AI_cachan_admin/.env.example AI_cachan_admin/.env

setting_db:
	@make artisan_ C="migrate:fresh"
	@make artisan_ C="db:seed"
	@make artisan_admin_ C="db:seed"


# setting_laravel_base:
# 	mkdir core/packages
# 	git clone git@gitlab.dev-ci.jp:ci-templates/laravel_base/common.git core/packages/laravel_base/common
# 	git clone git@gitlab.dev-ci.jp:ci-templates/laravel_base/users_core.git core/packages/laravel_base/user
# 	git clone git@gitlab.dev-ci.jp:ci-templates/laravel_base/admin_core.git core/packages/laravel_base/admin


# 環境構築コマンド
install:
	@git submodule init
	@git submodule update
#	 @make setting_laravel_base
	@make setting_file
	@make up
	@make composer C="install"
	@make composer_admin C="install"
	@make artisan_ C="key:generate"
	@make artisan_admin_ C="key:generate"
	@make setting_db

