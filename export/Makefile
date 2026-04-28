SHELL := /usr/bin/env bash

SAFE_MINT := ./scripts/mint-safe.sh
PORT ?= 3000
ARGS ?=

.DEFAULT_GOAL := help

.PHONY: help dev validate export export-unzip clean-export

help:
	@echo "Available targets:"
	@echo "  make dev PORT=3000      - start local preview safely"
	@echo "  make validate            - run Mint validation safely"
	@echo "  make export              - generate export.zip safely"
	@echo "  make export-unzip        - generate and unzip export.zip into export/"
	@echo "  make clean-export        - remove local export artifacts"

# Uses scripts/mint-safe.sh, which temporarily moves export folders out of root.
dev:
	$(SAFE_MINT) --port $(PORT) $(ARGS)

validate:
	$(SAFE_MINT) validate

export:
	$(SAFE_MINT) export $(ARGS)

export-unzip: export
	rm -rf export export__tmp
	mkdir -p export
	unzip -o export.zip -d export/
	rm -f export.zip

clean-export:
	rm -rf export export__tmp export.zip
