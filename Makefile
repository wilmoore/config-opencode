SHELL := /bin/bash

ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
OPENCODE_DIR ?= $(HOME)/.config/opencode
COMMANDS_DIR := $(OPENCODE_DIR)/commands
PRO_SOURCE_DIR := $(ROOT_DIR)/opencode/pro/commands

NS ?= colon

COLON_COMMAND_NAMES := pro:feature.md pro:pr.md pro:pr.merged.md
SLASH_LINK := $(COMMANDS_DIR)/pro

.PHONY: install uninstall status doctor

install: doctor
	@mkdir -p "$(COMMANDS_DIR)"
	@if [[ "$(NS)" == "slash" ]]; then \
		$(MAKE) --no-print-directory install-slash; \
	elif [[ "$(NS)" == "colon" ]]; then \
		$(MAKE) --no-print-directory install-colon; \
	else \
		echo "Error: unsupported NS='$(NS)'. Use NS=colon or NS=slash."; \
		exit 1; \
	fi

install-colon:
	@for entry in $(COLON_COMMAND_NAMES); do \
		dest="$(COMMANDS_DIR)/$$entry"; \
		source_name="$${entry#pro:}"; \
		source="$(PRO_SOURCE_DIR)/$$source_name"; \
		if [[ -e "$$dest" && ! -L "$$dest" ]]; then \
			echo "Error: $$dest exists and is not a symlink. Remove or rename it, then retry."; \
			exit 1; \
		fi; \
		if [[ -L "$$dest" ]]; then \
			target="$$(readlink "$$dest")"; \
			if [[ "$$target" != "$$source" ]]; then \
				echo "Error: $$dest points to $$target (expected $$source)."; \
				echo "Run: make uninstall"; \
				exit 1; \
			fi; \
			echo "OK: $$dest already linked"; \
		else \
			ln -s "$$source" "$$dest"; \
			echo "Linked: $$dest -> $$source"; \
		fi; \
	done
	@echo "Installed pro command stubs with colon namespace."
	@echo "Try: /pro:feature, /pro:pr, /pro:pr.merged"

install-slash:
	@if [[ -e "$(SLASH_LINK)" && ! -L "$(SLASH_LINK)" ]]; then \
		echo "Error: $(SLASH_LINK) exists and is not a symlink. Remove or rename it, then retry."; \
		exit 1; \
	fi
	@if [[ -L "$(SLASH_LINK)" ]]; then \
		target="$$(readlink "$(SLASH_LINK)")"; \
		if [[ "$$target" != "$(PRO_SOURCE_DIR)" ]]; then \
			echo "Error: $(SLASH_LINK) points to $$target (expected $(PRO_SOURCE_DIR))."; \
			echo "Run: make uninstall"; \
			exit 1; \
		fi; \
		echo "OK: $(SLASH_LINK) already linked"; \
	else \
		ln -s "$(PRO_SOURCE_DIR)" "$(SLASH_LINK)"; \
		echo "Linked: $(SLASH_LINK) -> $(PRO_SOURCE_DIR)"; \
	fi
	@echo "Installed pro command stubs with slash namespace."
	@echo "Try: /pro/feature, /pro/pr, /pro/pr.merged"

uninstall:
	@set -e; \
	for entry in $(COLON_COMMAND_NAMES); do \
		path="$(COMMANDS_DIR)/$$entry"; \
		if [[ -L "$$path" ]]; then \
			rm "$$path"; \
			echo "Removed: $$path"; \
		elif [[ -e "$$path" ]]; then \
			echo "Error: $$path exists and is not a symlink; refusing to remove."; \
			exit 1; \
		fi; \
	done; \
	if [[ -L "$(SLASH_LINK)" ]]; then \
		rm "$(SLASH_LINK)"; \
		echo "Removed: $(SLASH_LINK)"; \
	elif [[ -e "$(SLASH_LINK)" ]]; then \
		echo "Error: $(SLASH_LINK) exists and is not a symlink; refusing to remove."; \
		exit 1; \
	fi
	@echo "Uninstall complete."

status:
	@echo "Repo source: $(PRO_SOURCE_DIR)"
	@echo "Global commands dir: $(COMMANDS_DIR)"
	@if [[ -d "$(PRO_SOURCE_DIR)" ]]; then \
		echo "Source directory exists"; \
	else \
		echo "Source directory missing"; \
	fi
	@for source in feature.md pr.md pr.merged.md; do \
		if [[ -f "$(PRO_SOURCE_DIR)/$$source" ]]; then \
			echo "Source file OK: $(PRO_SOURCE_DIR)/$$source"; \
		else \
			echo "Source file missing: $(PRO_SOURCE_DIR)/$$source"; \
		fi; \
	done
	@for entry in $(COLON_COMMAND_NAMES); do \
		path="$(COMMANDS_DIR)/$$entry"; \
		if [[ -L "$$path" ]]; then \
			echo "Colon link: $$path -> $$(readlink "$$path")"; \
		elif [[ -e "$$path" ]]; then \
			echo "Colon path exists (not symlink): $$path"; \
		else \
			echo "Colon link missing: $$path"; \
		fi; \
	done
	@if [[ -L "$(SLASH_LINK)" ]]; then \
		echo "Slash link: $(SLASH_LINK) -> $$(readlink "$(SLASH_LINK)")"; \
	elif [[ -e "$(SLASH_LINK)" ]]; then \
		echo "Slash path exists (not symlink): $(SLASH_LINK)"; \
	else \
		echo "Slash link missing: $(SLASH_LINK)"; \
	fi

doctor:
	@for path in "$(ROOT_DIR)" "$(OPENCODE_DIR)" "$(PRO_SOURCE_DIR)"; do \
		if [[ ! -e "$$path" ]]; then \
			echo "Error: required path missing: $$path"; \
			exit 1; \
		fi; \
	done
	@for source in feature.md pr.md pr.merged.md; do \
		if [[ ! -f "$(PRO_SOURCE_DIR)/$$source" ]]; then \
			echo "Error: missing stub command file: $(PRO_SOURCE_DIR)/$$source"; \
			exit 1; \
		fi; \
	done
	@echo "Doctor checks passed."
