.PHONY: format

format:
	dune build @fmt --auto-promote

build:
	dune build

run:
	dune exec ./server/bin/main.exe
