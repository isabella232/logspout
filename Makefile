NAME=objectpartners/logspout
VERSION=$(shell cat VERSION)
CIRCLE_TAG ?= $(VERSION)

dev:
	@docker history $(NAME):dev &> /dev/null \
		|| docker build -f Dockerfile.dev -t $(NAME):dev .
	@docker run --rm \
		-e DEBUG=true \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(PWD):/go/src/github.com/gliderlabs/logspout \
		-p 8000:80 \
		-e ROUTE_URIS=$(ROUTE) \
		$(NAME):dev

build:
	mkdir -p build
	docker build -t $(NAME):$(VERSION) .

release:
	docker login -e $(DOCKER_EMAIL) -u $(DOCKER_USER) -p $(DOCKER_PASS)
	docker push $(NAME):$(VERSION)

circleci:
	rm ~/.gitconfig
	echo $(CIRCLE_TAG) > VERSION

clean:
	rm -rf build/
	docker rm $(shell docker ps -aq) || true
	docker rmi $(NAME):dev $(NAME):$(VERSION) || true
	docker rmi $(shell docker images -f 'dangling=true' -q) || true

.PHONY: release clean
