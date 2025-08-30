# Create the .env file if it doesn't exist
ifeq ($(wildcard infra/.env),)
$(shell cp infra/.env.dist infra/.env)
$(info $(shell printf "\033[32mINFO: no \".env\" file was found at infra/.env, it has been created from infra/.env.dist\033[0m\n"))
endif

# load the .env
-include infra/.env

PROJECT_NAME=$(shell grep '"name"' composer.json | head -1 | sed 's/.*"name":\s*"\([^"]*\)".*/\1/' | sed 's/\//-/g')-${PROJECT_TYPE}
DOCKERFILE=infra/${PROJECT_TYPE}.Dockerfile

build: # Build the Docker image
	@docker ps -a -q --filter "name=$(PROJECT_NAME)" | grep -q . && docker rm $(PROJECT_NAME) || true
	@docker build -t $(PROJECT_NAME) -f $(DOCKERFILE) --build-arg USER_ID=$(shell id -u) --build-arg GROUP_ID=$(shell id -g) .

start: stop # Start the Docker container
	@if ! docker ps -q --filter "name=$(PROJECT_NAME)" | grep -q .; then \
		make build; \
	fi
	@if [ "$(PROJECT_TYPE)" = "cli" ]; then \
		docker run -it -d --name $(PROJECT_NAME) --user $(shell id -u):$(shell id -g) --env-file infra/.env -v $(PWD):/var/www/html $(PROJECT_NAME); \
	else \
		docker run -d -p $(WEB_PORT):80 --name $(PROJECT_NAME) --user $(shell id -u):$(shell id -g) --env-file infra/.env -v $(PWD):/var/www/html $(PROJECT_NAME); \
	fi
	@make exec composer install

stop: # Stop the Docker container
	@docker ps -q --filter "name=$(PROJECT_NAME)" | grep -q . && docker stop $(PROJECT_NAME) || true

restart: stop start # Restart the Docker container

rebuild: stop build start # Rebuild the Docker image and start the container

remove: stop # Remove the Docker container
	@docker ps -a -q --filter "name=$(PROJECT_NAME)" | grep -q . && docker rm $(PROJECT_NAME) || true

cli: # Run a terminal inside the container
	@if ! docker ps -q --filter "name=$(PROJECT_NAME)" | grep -q .; then \
		make start; \
	fi
	@docker exec -it $(PROJECT_NAME) /bin/bash

logs: # Show the Docker container's logs
	@docker logs -f $(PROJECT_NAME)

clean: # Clean the Docker system
	@docker system prune -f

exec: # Execute a command inside the container
	@docker exec -it $(PROJECT_NAME) $(filter-out $@,$(MAKECMDGOALS))

help: # Display this help
	@echo ""
	@echo "\033[33mDocker commands:\033[0m"
	@echo ""
	@awk '/^[a-zA-Z_-]+:.*#/ { target = $$1; gsub(/:/, "", target); comment = ""; for(i=2; i<=NF; i++) if($$i ~ /^#/) { for(j=i+1; j<=NF; j++) comment = comment " " $$j; break } printf "\033[36mmake %-10s\033[0m%s\n", target, comment }' $(MAKEFILE_LIST)
	@echo ""
	@echo "\033[33mComposer commands:\033[0m"
	@echo ""
	@sed -n '/\"scripts-descriptions\":/,/^[[:space:]]*}/p' composer.json | grep -E '^[[:space:]]*"[^"]+":.*"' | sed 's/^[[:space:]]*"\([^"]*\)":[[:space:]]*"\(.*\)",*$$/\1|\2/' | awk -F'|' '{printf "\033[36mcomposer %-15s\033[0m%s\n", $$1, $$2}'
	@echo ""

%:
	@:

.PHONY: start stop restart rebuild remove cli exec logs clean