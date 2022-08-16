CURRENT_UID := $(shell id -u)
# CURRENT_GID := $(shell id -g)
CURRENT_GID := ${CURRENT_UID}
MODELS_DIR ?= $(shell pwd)
PORT ?= 8080
OCAML_COMPILER_MAJOR := 4.14
OCAML_COMPILER_MINOR := 0
OCAML_COMPILER := ${OCAML_COMPILER_MAJOR}.${OCAML_COMPILER_MINOR}

DC_RUN_VARS := USER_NAME=${USER} \
	CURRENT_UID=${CURRENT_UID} \
	CURRENT_GID=${CURRENT_GID} \
	REPO=${REPO} \
	IMAGE_TAG=release \
	MODELS_DIR=${MODELS_DIR} \
	PORT=${PORT} \
	OCAML_COMPILER=${OCAML_COMPILER} \
	OCAML_COMPILER_MAJOR=${OCAML_COMPILER_MAJOR}


.PHONY: format docker-run-arm docker-build

format:
	dune build @fmt --auto-promote

build:
	dune build

run:
	dune exec ./server/bin/main.exe

docker-run-arm:
	sudo ${DC_RUN_VARS} docker-compose -f docker-compose-arm.yml run --service-ports ocaml_tsne bash

docker-build-arm:
	sudo ${DC_RUN_VARS} docker-compose -f docker-compose-arm.yml build
