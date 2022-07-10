.PHONY: help

TITLE_MAKEFILE=Kasm Ubuntu Bionic

SHELL=/bin/bash
.SHELLFLAGS += -o pipefail
.ONESHELL:

export CURRENT_DIR := $(shell pwd)
export RED := $(shell tput setaf 1)
export RESET := $(shell tput sgr0)
export DATE_NOW := $(shell date)

IMAGE := "ghcr.io/manprint/ubuntu-jammy-dind-vnc:latest"
GITHUB_CREDS := $(shell pass Github/Manprint/Token)

.DEFAULT := help

help:
	@printf "\n$(RED)$(TITLE_MAKEFILE)$(RESET)\n"
	@awk 'BEGIN {FS = ":.*##"; printf "\n\033[1mUsage:\n  make \033[36m<target>\033[0m\n"} \
	/^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2 } /^##@/ \
	{ printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo


##@ Build Image

clean: ## Docker image prune and builder prune
	-@echo "y" | docker image prune
	-@echo "y" | docker builder prune
	-@echo "y" | docker volume prune

build: clean ## Build docker image
	@DOCKER_BUILDKIT=1 docker build --force-rm --rm --tag ${IMAGE} .

build_no_cache: clean ## Build docker image no cache
	@DOCKER_BUILDKIT=1 docker build --no-cache --force-rm --rm --tag ${IMAGE} .

pull: ## Pull image
	@docker pull $(IMAGE)

publish: build ## Push image
	@echo "$(RED)Create in repo folder the "github.token" file for publish image...$(RESET)"
	echo ${GITHUB_CREDS} | docker login ghcr.io -u manprint --password-stdin
	@docker push ${IMAGE}
	$(MAKE) clean
