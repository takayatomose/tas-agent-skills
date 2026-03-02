BINARY  := tas-agent
CMD     := ./cmd/tas-agent
DIST    := dist

# Version from git tag or "dev"
VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
LDFLAGS := -ldflags "-X main.version=$(VERSION) -s -w"

.PHONY: build build-all install clean test

## build: Build for the current platform
build:
	@mkdir -p $(DIST)
	go build $(LDFLAGS) -o $(DIST)/$(BINARY) $(CMD)
	@echo "Built: $(DIST)/$(BINARY)"

## build-all: Cross-compile for all supported platforms
build-all: clean
	@mkdir -p $(DIST)
	@echo "Building $(BINARY) $(VERSION) for all platforms...\n"

	GOOS=darwin  GOARCH=amd64 go build $(LDFLAGS) -o $(DIST)/$(BINARY)-darwin-amd64  $(CMD)
	GOOS=darwin  GOARCH=arm64 go build $(LDFLAGS) -o $(DIST)/$(BINARY)-darwin-arm64  $(CMD)
	GOOS=linux   GOARCH=amd64 go build $(LDFLAGS) -o $(DIST)/$(BINARY)-linux-amd64   $(CMD)
	GOOS=linux   GOARCH=arm64 go build $(LDFLAGS) -o $(DIST)/$(BINARY)-linux-arm64   $(CMD)
	GOOS=windows GOARCH=amd64 go build $(LDFLAGS) -o $(DIST)/$(BINARY)-windows-amd64.exe $(CMD)

	@echo "\nBuilt binaries:"
	@ls -lh $(DIST)/

## install: Build and install to /usr/local/bin (requires write permission)
install: build
	cp $(DIST)/$(BINARY) /usr/local/bin/$(BINARY)
	@echo "Installed: /usr/local/bin/$(BINARY)"

## install-user: Build and install to ~/bin (no sudo required)
install-user: build
	@mkdir -p $(HOME)/bin
	cp $(DIST)/$(BINARY) $(HOME)/bin/$(BINARY)
	@echo "Installed: $(HOME)/bin/$(BINARY)"
	@echo "Make sure $(HOME)/bin is in your PATH"

## clean: Remove build artifacts
clean:
	rm -rf $(DIST)

## test: Quick smoke test of the built binary
test: build
	@echo "--- version ---"
	$(DIST)/$(BINARY) version
	@echo "\n--- list ---"
	$(DIST)/$(BINARY) list
	@echo "\n--- list be ---"
	$(DIST)/$(BINARY) list be
	@echo "\n--- install be --dry-run ---"
	$(DIST)/$(BINARY) install be --dry-run --target /tmp/tas-test

help:
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## /  /'
