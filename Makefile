IMAGE_NAME=php-app
CONTAINER_NAME=php_app_container

# Build the Docker image
build:
	@docker build -t $(IMAGE_NAME) -f docker/Dockerfile .

# Start the Docker container. If it's already running, stop and remove the previous instance.
start: remove
	@docker run -d -p 8080:80 --name $(CONTAINER_NAME) $(IMAGE_NAME)

# Stop the Docker container
stop:
	@docker ps -q --filter "name=$(CONTAINER_NAME)" | grep -q . && docker stop $(CONTAINER_NAME) || true

# Restart the Docker container
restart: stop start

# Rebuild the Docker image and start the container
rebuild: stop build start

# Remove the Docker container
remove: stop
	@docker ps -a -q --filter "name=$(CONTAINER_NAME)" | grep -q . && docker rm $(CONTAINER_NAME) || true

# Access the Docker image's CLI
cli:
	@docker exec -it $(CONTAINER_NAME) /bin/bash

# Show the Docker container's logs
logs:
	@docker logs -f $(CONTAINER_NAME)

# Clean the Docker system
clean:
	@docker system prune -f

.PHONY: start stop restart rebuild remove cli logs clean