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

# Validate that ENVIRONMENT is set
ifeq ($(ENVIRONMENT),)
$(error ENVIRONMENT variable is not set. Please create infra/.env from infra/.env.dist and set ENVIRONMENT)
endif

PROJECT_NAME := $(shell grep -E '"name":' composer.json | head -n 1 | cut -d'"' -f4 | tr '/' '-')
export PROJECT_NAME
COMPOSE_FILE := infra/$(ENVIRONMENT)/docker-compose.yml
COMPOSE_CMD := docker compose -f $(COMPOSE_FILE)
DOCKER_NAME := app-$(ENVIRONMENT)

check-docker:
	@docker info > /dev/null 2>&1 || (echo "Error: Docker daemon is not running" && exit 1)
	@docker compose version > /dev/null 2>&1 || (echo "Error: docker compose is not available" && exit 1)

check-compose-file:
	@test -f $(COMPOSE_FILE) || (echo "Error: Compose file not found: $(COMPOSE_FILE)" && exit 1)

check-composer:
	@test -f composer.json || (echo "Error: composer.json not found" && exit 1)


install: check-docker check-compose-file check-composer start # Install composer dependencies
	$(COMPOSE_CMD) exec $(DOCKER_NAME) composer install

start: check-docker check-compose-file # Start the Docker container
	$(COMPOSE_CMD) up -d $(DOCKER_NAME)

stop: check-docker check-compose-file # Stop the Docker container
	$(COMPOSE_CMD) down

restart: stop start # Restart the Docker container

shell: check-docker check-compose-file start # Open a shell (using SHELL variable) inside the container
	$(COMPOSE_CMD) exec $(DOCKER_NAME) $(SHELL)

bash: check-docker check-compose-file start # Open bash inside the container
	$(COMPOSE_CMD) exec $(DOCKER_NAME) /bin/bash

exec: check-docker check-compose-file # Execute a command inside the container (usage: make exec -- <command>)
	@if [ -z "$$($(COMPOSE_CMD) ps -q $(DOCKER_NAME))" ]; then \
		echo "Container not running, starting it..."; \
		$(COMPOSE_CMD) up -d $(DOCKER_NAME); \
	fi
ifdef ARGS
	$(COMPOSE_CMD) exec $(DOCKER_NAME) sh -c '$(ARGS)'
else
	$(COMPOSE_CMD) exec $(DOCKER_NAME) $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
endif

test: check-docker check-compose-file check-composer start # Run tests
	$(COMPOSE_CMD) exec $(DOCKER_NAME) composer fulltest

build: check-docker check-compose-file # Build the Docker image
	$(COMPOSE_CMD) build --no-cache

rebuild: stop build start # Rebuild the Docker image and start the container

remove: check-docker check-compose-file # Remove the Docker container and volumes
	$(COMPOSE_CMD) down -v --remove-orphans

logs: check-docker check-compose-file # Show the Docker container's logs
	$(COMPOSE_CMD) logs -f

ps: check-docker check-compose-file # Show container status
	$(COMPOSE_CMD) ps

clean: check-docker # Clean the Docker system
	docker system prune -f

status: check-docker check-compose-file # Show container status
	@printf "\033[33mProject name:\033[0m\t\033[32m%s\033[0m\n" "$(PROJECT_NAME)"
	@printf "\033[33mEnvironment:\033[0m\t\033[32m%s\033[0m\n" "$(ENVIRONMENT)"
	@printf "\033[33mContainer name:\033[0m\t\033[32m%s\033[0m\n" "$(DOCKER_NAME)"
	@printf "\033[33mStatus:\033[0m\n"
	@$(COMPOSE_CMD) ps

help: # Display this help
	@printf "\n"
	@printf "\033[33mDocker Compose commands:\033[0m\n"
	@printf "\n"
	@awk '/^[a-zA-Z_-]+:.*#/ { \
		target = $$1; \
		gsub(/:/, "", target); \
		comment = ""; \
		for(i=2; i<=NF; i++) { \
			if($$i ~ /^#/) { \
				for(j=i+1; j<=NF; j++) { \
					comment = comment " " $$j; \
				} \
				break; \
			} \
		} \
		printf "\033[36mmake %-15s\033[0m%s\n", target, comment; \
	}' $(MAKEFILE_LIST)
	@printf "\n"
	@printf "\033[33mComposer commands:\033[0m\n"
	@printf "\n"
	@if [ -f composer.json ]; then \
		sed -n '/"scripts":/,/^[[:space:]]*}/p' composer.json | \
		grep -E '^[[:space:]]*"[^"]+":' | \
		sed 's/^[[:space:]]*"\([^"]*\)":.*/\1/' | \
		grep -v '^scripts$$' | \
		while read -r script; do \
			desc=$$(sed -n "/\"scripts-descriptions\":/,/^[[:space:]]*}/p" composer.json 2>/dev/null | \
				grep "\"$$script\":" | \
				sed 's/^[[:space:]]*"[^"]*":[[:space:]]*"\(.*\)",*/\1/' || echo ""); \
			if [ -n "$$desc" ]; then \
				printf "\033[36mcomposer %-15s\033[0m%s\n" "$$script" "$$desc"; \
			else \
				printf "\033[36mcomposer %-15s\033[0m\n" "$$script"; \
			fi; \
		done; \
	fi
	@printf "\n"

VALID_TARGETS := start stop restart cli shell bash exec build rebuild remove logs ps pull clean install test status help check-docker check-compose-file check-composer
%:
	@if echo "$(MAKECMDGOALS)" | grep -q "^exec"; then \
		: ; \
	else \
		target="$@"; \
		if ! echo "$(VALID_TARGETS)" | grep -qw "$$target"; then \
			printf "\033[33mWarning: Unknown target '%s'\033[0m\n" "$$target" >&2; \
			printf "Valid targets are: %s\n" "$(VALID_TARGETS)" >&2; \
			printf "Run 'make help' for more information\n" >&2; \
			exit 1; \
		fi; \
	fi
	@:

.DEFAULT_GOAL := help

.PHONY: start stop restart shell bash exec build rebuild remove logs ps clean install test status help check-docker check-compose-file check-composer