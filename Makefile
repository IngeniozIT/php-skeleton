# load the .env
-include infra/.env.dist
-include infra/.env

PROJECT_NAME=$(shell grep '"name"' composer.json | head -1 | sed 's/.*"name":\s*"\([^"]*\)".*/\1/' | sed 's/\//-/g')-${PROJECT_TYPE}

# dockerfile + env
DOCKERFILE=infra/${PROJECT_TYPE}.Dockerfile

# Build the Docker image
build:
	@docker build -t $(PROJECT_NAME) -f $(DOCKERFILE) .

# Start the Docker container. If it's already running, stop and remove the previous instance.
start: remove
	@docker run -d -p 8080:80 --name $(PROJECT_NAME) -v $(PWD):/var/www/html $(PROJECT_NAME)

# Stop the Docker container
stop:
	@docker ps -q --filter "name=$(PROJECT_NAME)" | grep -q . && docker stop $(PROJECT_NAME) || true

# Restart the Docker container
restart: stop start

# Rebuild the Docker image and start the container
rebuild: stop build start

# Remove the Docker container
remove: stop
	@docker ps -a -q --filter "name=$(PROJECT_NAME)" | grep -q . && docker rm $(PROJECT_NAME) || true

# Access the Docker image's CLI
cli:
	@docker exec -it $(PROJECT_NAME) /bin/bash

# Show the Docker container's logs
logs:
	@docker logs -f $(PROJECT_NAME)

# Clean the Docker system
clean:
	@docker system prune -f

.PHONY: start stop restart rebuild remove cli logs clean