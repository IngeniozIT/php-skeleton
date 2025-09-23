# Create the .env files if they don't exist
define copy_env_if_missing
$(if $(wildcard $(1)),, \
	$(shell cp $(1).dist $(1)) \
	$(info $(shell printf "\033[32mINFO: \"$(1)\" file was created from $(1).dist\033[0m\n")) \
)
endef
ENV_DIST_FILES := $(shell find infra -maxdepth 2 -name "*.env.dist" 2>/dev/null)
ENV_FILES := $(ENV_DIST_FILES:.env.dist=.env)
$(foreach env_file,$(ENV_FILES),$(call copy_env_if_missing,$(env_file)))

# load the environment variables
-include infra/.env
-include infra/$(ENVIRONMENT)/.env

export ENVIRONMENT
export PHP_VERSION
PROJECT_NAME := $(shell grep -E '"name":' composer.json | head -n 1 | cut -d'"' -f4 | tr '/' '-')
export PROJECT_NAME
COMPOSE_FILE = infra/$(ENVIRONMENT)/docker-compose.yml
COMPOSE_CMD = docker compose -f $(COMPOSE_FILE)
DOCKER_NAME = app-$(ENVIRONMENT)

start: # Start the Docker container
	@$(COMPOSE_CMD) up -d $(DOCKER_NAME)
	@$(COMPOSE_CMD) exec $(DOCKER_NAME) composer install

stop: # Stop the Docker container
	@$(COMPOSE_CMD) down

restart: stop start # Restart the Docker container

cli: # Run a terminal inside the container
	@$(COMPOSE_CMD) up -d $(DOCKER_NAME)
	$(COMPOSE_CMD) exec $(DOCKER_NAME) /bin/bash

exec: # Execute a command inside the container
	@$(COMPOSE_CMD) exec $(DOCKER_NAME) $(filter-out $@,$(MAKECMDGOALS))

build: # Build the Docker image
	@$(COMPOSE_CMD) build --no-cache

rebuild: stop build start # Rebuild the Docker image and start the container

remove: # Remove the Docker container and volumes
	@$(COMPOSE_CMD) down -v --remove-orphans

logs: # Show the Docker container's logs
	@$(COMPOSE_CMD) logs -f

clean: # Clean the Docker system
	@docker system prune -f

status: # Show container status
	@echo "\033[33mProject name:\033[0m\\t\033[32m$(PROJECT_NAME)\033[0m"
	@echo "\033[33mEnvironment:\033[0m\\t\033[32m$(ENVIRONMENT)\033[0m"
	@echo "\033[33mDocker name:\033[0m\\t\033[32m$(PROJECT_NAME)-$(ENVIRONMENT)\033[0m"
	@echo "\033[33mStatus:\033[0m"
	@$(COMPOSE_CMD) ps

help: # Display this help
	@echo ""
	@echo "\033[33mDocker Compose commands:\033[0m"
	@echo ""
	@awk '/^[a-zA-Z_-]+:.*#/ { target = $$1; gsub(/:/, "", target); comment = ""; for(i=2; i<=NF; i++) if($$i ~ /^#/) { for(j=i+1; j<=NF; j++) comment = comment " " $$j; break } printf "\033[36mmake %-10s\033[0m%s\n", target, comment }' $(MAKEFILE_LIST)
	@echo ""
	@echo "\033[33mComposer commands:\033[0m"
	@echo ""
	@sed -n '/\"scripts-descriptions\":/,/^[[:space:]]*}/p' composer.json | grep -E '^[[:space:]]*"[^"]+":.*"' | sed 's/^[[:space:]]*"\([^"]*\)":[[:space:]]*"\(.*\)",*$$/\1|\2/' | awk -F'|' '{printf "\033[36mcomposer %-15s\033[0m%s\n", $$1, $$2}'
	@echo ""

%:
	@:

.PHONY: start stop restart cli exec build rebuild remove logs clean status