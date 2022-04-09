docker:
	DOCKER_BUILDKIT=1 docker build -t leonardopc/code-server-go .

run:
	docker-compose up -d