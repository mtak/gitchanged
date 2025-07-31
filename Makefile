# Image settings
IMAGE_NAME=merijntjetak/gitchanged
IMAGE_TAG=latest

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

# Push the image to Docker Hub
push: build
	docker push $(IMAGE_NAME):$(IMAGE_TAG)

# Clean up local image
clean:
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG) || true

# Rebuild from scratch
rebuild: clean build

# Run with Docker Compose
run:
	docker-compose run --rm gitchanged

