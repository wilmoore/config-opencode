SHELL := /bin/bash

ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
OPENCODE_DIR ?= $(HOME)/.config/opencode
COMMANDS_DIR := $(OPENCODE_DIR)/commands
PLUGINS_DIR := $(OPENCODE_DIR)/plugins
PRO_SOURCE_DIR := $(ROOT_DIR)/opencode/pro/commands
PRO_HANDOFF_PLUGIN_SOURCE := $(ROOT_DIR)/opencode/pro/plugins/session-handoff.js
PRO_HANDOFF_PLUGIN_LINK := $(PLUGINS_DIR)/pro-session-handoff.js

COMMAND_FILES := $(notdir $(wildcard $(PRO_SOURCE_DIR)/*.md))
COLON_COMMAND_NAMES := $(patsubst %,pro:%,$(COMMAND_FILES))
COMMAND_COUNT := $(words $(COMMAND_FILES))

.PHONY: help install install-commands install-plugins uninstall uninstall-commands uninstall-plugins status doctor

help:
	@printf "%s\n" \
	  "Usage: make [target]" \
	  "" \
	  "Primary targets:" \
	  "  help                 Show this usage summary" \
	  "  install              Install commands and plugins" \
	  "  uninstall            Remove commands and plugins" \
	  "  status               Show current command/plugin link status under $(COMMANDS_DIR)" \
	  "  doctor               Validate repo and command source prerequisites" \
	  "" \
	  "Advanced targets:" \
	  "  install-commands     Install only /pro commands (auto-detected colon namespace)" \
	  "  install-plugins      Install all available plugins (currently session-handoff)" \
	  "  uninstall-commands   Remove only /pro command links" \
	  "  uninstall-plugins    Remove all plugin links" \
	  "" \
	  "Examples:" \
	  "  make install                # Install commands + plugins" \
	  "  make install-commands       # Install commands only" \
	  "  make install-plugins        # Install plugins only" \
	  "  make status                 # Inspect current link state"

install: doctor install-commands install-plugins
	@echo "Install complete."

install-commands:
	@mkdir -p "$(COMMANDS_DIR)"
	@if [[ -z "$(COMMAND_FILES)" ]]; then \
		echo "Error: no command files found under $(PRO_SOURCE_DIR)."; \
		exit 1; \
	fi
	$(MAKE) --no-print-directory install-colon
	@echo "Installed $$(test -n "$(COMMAND_COUNT)" && echo $(COMMAND_COUNT) || echo 0) commands."

install-plugins:
	@mkdir -p "$(PLUGINS_DIR)"
	@if [[ ! -f "$(PRO_HANDOFF_PLUGIN_SOURCE)" ]]; then \
		echo "Error: missing source plugin: $(PRO_HANDOFF_PLUGIN_SOURCE)"; \
		exit 1; \
	fi
	@if [[ -e "$(PRO_HANDOFF_PLUGIN_LINK)" && ! -L "$(PRO_HANDOFF_PLUGIN_LINK)" ]]; then \
		echo "Error: $(PRO_HANDOFF_PLUGIN_LINK) exists and is not a symlink. Remove or rename it, then retry."; \
		exit 1; \
	fi
	@if [[ -L "$(PRO_HANDOFF_PLUGIN_LINK)" ]]; then \
		target="$$(readlink "$(PRO_HANDOFF_PLUGIN_LINK)")"; \
		if [[ "$$target" != "$(PRO_HANDOFF_PLUGIN_SOURCE)" ]]; then \
			echo "Error: $(PRO_HANDOFF_PLUGIN_LINK) points to $$target (expected $(PRO_HANDOFF_PLUGIN_SOURCE))."; \
			echo "Run: make uninstall-plugins to repair the link."; \
			exit 1; \
		fi; \
		echo "OK: $(PRO_HANDOFF_PLUGIN_LINK) already linked"; \
	else \
		ln -s "$(PRO_HANDOFF_PLUGIN_SOURCE)" "$(PRO_HANDOFF_PLUGIN_LINK)"; \
		echo "Linked: $(PRO_HANDOFF_PLUGIN_LINK) -> $(PRO_HANDOFF_PLUGIN_SOURCE)"; \
	fi
	@echo "Installed plugins."

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
	@echo "Linked $(COMMAND_COUNT) pro commands under the colon namespace."
uninstall: uninstall-commands uninstall-plugins
	@echo "Uninstall complete."

uninstall-commands:
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
	done
	@echo "Removed command links."


uninstall-plugins:
	@if [[ -L "$(PRO_HANDOFF_PLUGIN_LINK)" ]]; then \
		rm "$(PRO_HANDOFF_PLUGIN_LINK)"; \
		echo "Removed: $(PRO_HANDOFF_PLUGIN_LINK)"; \
		echo "Removed plugins."; \
	elif [[ -e "$(PRO_HANDOFF_PLUGIN_LINK)" ]]; then \
		echo "Error: $(PRO_HANDOFF_PLUGIN_LINK) exists and is not a symlink; refusing to remove."; \
		exit 1; \
	else \
		echo "No plugin link found."; \
	fi

status:
	@echo "Repo source: $(PRO_SOURCE_DIR)"
	@echo "Global commands dir: $(COMMANDS_DIR)"
	@if [[ -d "$(PRO_SOURCE_DIR)" ]]; then \
		echo "Source directory exists"; \
	else \
		echo "Source directory missing"; \
	fi
	@if [[ -z "$(COMMAND_FILES)" ]]; then \
		echo "No command files detected under $(PRO_SOURCE_DIR)."; \
	else \
		echo "Command sources detected: $(COMMAND_COUNT)"; \
	fi
	@for source in $(COMMAND_FILES); do \
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
	@if [[ -L "$(PRO_HANDOFF_PLUGIN_LINK)" ]]; then \
		echo "Handoff plugin link: $(PRO_HANDOFF_PLUGIN_LINK) -> $$(readlink "$(PRO_HANDOFF_PLUGIN_LINK)")"; \
	elif [[ -e "$(PRO_HANDOFF_PLUGIN_LINK)" ]]; then \
		echo "Handoff plugin path exists (not symlink): $(PRO_HANDOFF_PLUGIN_LINK)"; \
	else \
		echo "Handoff plugin link missing: $(PRO_HANDOFF_PLUGIN_LINK)"; \
	fi

doctor:
	@for path in "$(ROOT_DIR)" "$(OPENCODE_DIR)" "$(PRO_SOURCE_DIR)"; do \
		if [[ ! -e "$$path" ]]; then \
			echo "Error: required path missing: $$path"; \
			exit 1; \
		fi; \
	done
	@if [[ -z "$(COMMAND_FILES)" ]]; then \
		echo "Error: no command files found under $(PRO_SOURCE_DIR)."; \
		exit 1; \
	fi
	@for source in $(COMMAND_FILES); do \
		if [[ ! -f "$(PRO_SOURCE_DIR)/$$source" ]]; then \
			echo "Error: missing command file: $(PRO_SOURCE_DIR)/$$source"; \
			exit 1; \
		fi; \
	done
	@echo "Doctor checks passed."
