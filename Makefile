.PHONY: format

format:
	dune build @fmt --auto-promote

run:
	dune exec ./server/bin/main.exe
