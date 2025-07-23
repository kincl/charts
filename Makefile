# Makefile for Skupper Hub Bridge Helm Package

# Variables
CHART_DIR := skupper-hub-bridge
REGISTRY := oci://ghcr.io/kincl

# Default target
.PHONY: all
all: build push

# Build Helm package
.PHONY: build
build:
	helm package $(CHART_DIR)

# Push latest Helm package to registry
.PHONY: push
push:
	$(eval LATEST_TGZ := $(shell ls -v $(CHART_DIR)-*.tgz 2>/dev/null | tail -n1))
	@if [ -n "$(LATEST_TGZ)" ]; then \
		helm push $(LATEST_TGZ) $(REGISTRY); \
	else \
		echo "No helm package found to push"; \
		exit 1; \
	fi

# Clean up generated packages
.PHONY: clean
clean:
	rm -f $(CHART_DIR)-*.tgz

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all     : Build and push Helm package"
	@echo "  build   : Create Helm package"
	@echo "  push    : Push latest Helm package to registry"
	@echo "  clean   : Remove generated packages"
	@echo "  help    : Show this help message"
