IMAGE_NAME := mysql
IMAGE_TAG := 5.7
CONTAINER_NAME := mysqldb
HOST_PORT := 3308

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

MAKE_DIR := $(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

.PHONY: all build clean create kill start stop restart shell docker_ip

all: create restart

build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

clean:
	docker images $(IMAGE_NAME) | grep -q $(IMAGE_TAG) && docker rmi $(IMAGE_NAME):$(IMAGE_TAG) || true

create:
	docker run --name $(CONTAINER_NAME) --restart=always -e MYSQL_ROOT_PASSWORD=root -d -p $(HOST_PORT):3306 -v $(MAKE_DIR)/config:/etc/mysql/conf.d -v $(MAKE_DIR)/data:/var/lib/mysql $(IMAGE_NAME):$(IMAGE_TAG)

kill:
	docker stop $(CONTAINER_NAME) && docker rm $(CONTAINER_NAME)

start:
	docker start $(CONTAINER_NAME)

stop:
	docker stop $(CONTAINER_NAME)

restart:
	docker restart $(CONTAINER_NAME)

shell:
	docker exec -it $(CONTAINER_NAME) bash

docker_ip:
	@ip addr show docker0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1
