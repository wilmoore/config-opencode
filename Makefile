SHELL := /bin/bash

ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
OPENCODE_DIR ?= $(HOME)/.config/opencode
COMMANDS_DIR := $(OPENCODE_DIR)/commands
PLUGINS_DIR := $(OPENCODE_DIR)/plugins

PRO_SOURCE_DIR := $(ROOT_DIR)/opencode/pro/commands
MAKE_SOURCE_DIR := $(ROOT_DIR)/opencode/make/commands
RULES_SOURCE_DIR := $(ROOT_DIR)/opencode/rules/commands

AGENTS_SOURCE := $(ROOT_DIR)/opencode/AGENTS.md
AGENTS_LINK := $(OPENCODE_DIR)/AGENTS.md
PRO_HANDOFF_PLUGIN_SOURCE := $(ROOT_DIR)/opencode/pro/plugins/session-handoff.js
PRO_HANDOFF_PLUGIN_LINK := $(PLUGINS_DIR)/pro-session-handoff.js

PLAN_SAFETY_PLUGIN_SOURCE := $(ROOT_DIR)/opencode/pro/plugins/auto-return-to-plan.js
PLAN_SAFETY_PLUGIN_LINK := $(PLUGINS_DIR)/pro-auto-return-to-plan.js

PRO_COMMAND_FILES := $(notdir $(wildcard $(PRO_SOURCE_DIR)/*.md))
MAKE_COMMAND_FILES := $(notdir $(wildcard $(MAKE_SOURCE_DIR)/*.md))
RULES_COMMAND_FILES := $(notdir $(wildcard $(RULES_SOURCE_DIR)/*.md))

PRO_COLON_COMMAND_NAMES := $(patsubst %,pro:%,$(PRO_COMMAND_FILES))
MAKE_COMMAND_NAMES := $(patsubst %,make:%,$(MAKE_COMMAND_FILES))
RULES_COMMAND_NAMES := $(patsubst %,rules:%,$(RULES_COMMAND_FILES))

TOTAL_COMMAND_COUNT := $(shell echo $$(( $(words $(PRO_COMMAND_FILES)) + $(words $(MAKE_COMMAND_FILES)) + $(words $(RULES_COMMAND_FILES)) )))

.PHONY: help install install-commands install-plugins install-agents install-pro install-make install-rules uninstall uninstall-commands uninstall-plugins uninstall-agents status doctor enable-plan-safety test

.DEFAULT_GOAL := help

help: ## Show this help
	@if [ -t 1 ] && command -v tput >/dev/null 2>&1; then \
		cyan=$$(tput setaf 6); bold=$$(tput bold); reset=$$(tput sgr0); \
		printf "\nUsage:\n  $${bold}make <target>$${reset}\n\n$${bold}Targets:$${reset}\n"; \
		awk -v cyan="$$cyan" -v bold="$$bold" -v reset="$$reset" 'BEGIN {FS = ":.*## "} /^[a-zA-Z0-9_.-]+:.*?## / { printf "  %s%-20s%s %s\n", cyan, $$1, reset, $$2 }' $(MAKEFILE_LIST); \
	else \
		printf "\nUsage:\n  make <target>\n\nTargets:\n"; \
		awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z0-9_.-]+:.*?## / { printf "  %-20s %s\n", $$1, $$2 }' $(MAKEFILE_LIST); \
	fi

install: install-commands install-plugins ## Install commands and plugins
	@echo "Install complete."

install-commands: ## Install /pro, /make, and /rules commands
	@mkdir -p "$(COMMANDS_DIR)"
	@if [[ -z "$(PRO_COMMAND_FILES)" && -z "$(MAKE_COMMAND_FILES)" && -z "$(RULES_COMMAND_FILES)" ]]; then \
		echo "Error: no command files found under $(PRO_SOURCE_DIR), $(MAKE_SOURCE_DIR), or $(RULES_SOURCE_DIR)."; \
		exit 1; \
	fi
	$(MAKE) --no-print-directory install-pro
	$(MAKE) --no-print-directory install-make
	$(MAKE) --no-print-directory install-rules
	@echo "Installed commands."

install-pro:
	@for entry in $(PRO_COLON_COMMAND_NAMES); do \
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
	@echo "Linked $(words $(PRO_COMMAND_FILES)) pro commands under the colon namespace."

install-make:
	@for entry in $(MAKE_COMMAND_NAMES); do \
		dest="$(COMMANDS_DIR)/$$entry"; \
		source_name="$${entry#make:}"; \
		source="$(MAKE_SOURCE_DIR)/$$source_name"; \
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
	@echo "Linked $(words $(MAKE_COMMAND_FILES)) make commands."

install-rules:
	@for entry in $(RULES_COMMAND_NAMES); do \
		dest="$(COMMANDS_DIR)/$$entry"; \
		source_name="$${entry#rules:}"; \
		source="$(RULES_SOURCE_DIR)/$$source_name"; \
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
	@echo "Linked $(words $(RULES_COMMAND_FILES)) rules commands."

install-agents: ## Install toolkit AGENTS.md (opt-in)
	@mkdir -p "$(OPENCODE_DIR)"
	@if [[ ! -f "$(AGENTS_SOURCE)" ]]; then \
		echo "Error: missing source file: $(AGENTS_SOURCE)"; \
		exit 1; \
	fi
	@if [[ -e "$(AGENTS_LINK)" && ! -L "$(AGENTS_LINK)" ]]; then \
		echo "Error: $(AGENTS_LINK) exists and is not a symlink. Refusing to overwrite."; \
		echo "Move it aside first, then rerun: make install-agents"; \
		exit 1; \
	fi
	@if [[ -L "$(AGENTS_LINK)" ]]; then \
		target="$$(readlink "$(AGENTS_LINK)")"; \
		if [[ "$$target" != "$(AGENTS_SOURCE)" ]]; then \
			echo "Error: $(AGENTS_LINK) points to $$target (expected $(AGENTS_SOURCE))."; \
			echo "Remove the symlink and rerun: make install-agents"; \
			exit 1; \
		fi; \
		echo "OK: $(AGENTS_LINK) already linked"; \
	else \
		ln -s "$(AGENTS_SOURCE)" "$(AGENTS_LINK)"; \
		echo "Linked: $(AGENTS_LINK) -> $(AGENTS_SOURCE)"; \
	fi

install-plugins: ## Install plugin symlinks
	@mkdir -p "$(PLUGINS_DIR)"
	$(MAKE) --no-print-directory install-pro-plugins
	@echo "Installed plugins."

install-pro-plugins:
	@set -e; \
	for pair in \
		"$(PRO_HANDOFF_PLUGIN_LINK)|$(PRO_HANDOFF_PLUGIN_SOURCE)" \
		"$(PLAN_SAFETY_PLUGIN_LINK)|$(PLAN_SAFETY_PLUGIN_SOURCE)" \
	; do \
		dest="$${pair%%|*}"; \
		source="$${pair#*|}"; \
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
uninstall: uninstall-commands uninstall-plugins ## Remove commands and plugins
	@echo "Uninstall complete."

uninstall-commands:
	@set -e; \
	for entry in $(PRO_COLON_COMMAND_NAMES); do \
		path="$(COMMANDS_DIR)/$$entry"; \
		if [[ -L "$$path" ]]; then \
			rm "$$path"; \
			echo "Removed: $$path"; \
		elif [[ -e "$$path" ]]; then \
			echo "Error: $$path exists and is not a symlink; refusing to remove."; \
			exit 1; \
		fi; \
	done
	@set -e; \
	for entry in $(MAKE_COMMAND_NAMES); do \
		path="$(COMMANDS_DIR)/$$entry"; \
		if [[ -L "$$path" ]]; then \
			rm "$$path"; \
			echo "Removed: $$path"; \
		elif [[ -e "$$path" ]]; then \
			echo "Error: $$path exists and is not a symlink; refusing to remove."; \
			exit 1; \
		fi; \
	done
	@set -e; \
	for entry in $(RULES_COMMAND_NAMES); do \
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

uninstall-agents: ## Remove toolkit AGENTS.md symlink
	@if [[ -L "$(AGENTS_LINK)" ]]; then \
		rm "$(AGENTS_LINK)"; \
		echo "Removed: $(AGENTS_LINK)"; \
	elif [[ -e "$(AGENTS_LINK)" ]]; then \
		echo "Error: $(AGENTS_LINK) exists and is not a symlink; refusing to remove."; \
		exit 1; \
	else \
		echo "No AGENTS.md symlink found."; \
	fi


uninstall-plugins: ## Remove plugin links
	@set -e; \
	removed=0; \
	for dest in "$(PRO_HANDOFF_PLUGIN_LINK)" "$(PLAN_SAFETY_PLUGIN_LINK)"; do \
		if [[ -L "$$dest" ]]; then \
			rm "$$dest"; \
			echo "Removed: $$dest"; \
			removed=1; \
		elif [[ -e "$$dest" ]]; then \
			echo "Error: $$dest exists and is not a symlink; refusing to remove."; \
			exit 1; \
		fi; \
	done; \
	if [[ "$$removed" -eq 1 ]]; then \
		echo "Removed plugins."; \
	else \
		echo "No plugin links found."; \
	fi

status: ## Show current command/plugin link status
	@echo "Repo source: $(PRO_SOURCE_DIR)"
	@echo "Rules source: $(RULES_SOURCE_DIR)"
	@echo "Global commands dir: $(COMMANDS_DIR)"
	@if [[ -d "$(PRO_SOURCE_DIR)" ]]; then \
		echo "Source directory exists"; \
	else \
		echo "Source directory missing"; \
	fi
	@if [[ -z "$(PRO_COMMAND_FILES)" && -z "$(MAKE_COMMAND_FILES)" && -z "$(RULES_COMMAND_FILES)" ]]; then \
		echo "No command files detected under $(PRO_SOURCE_DIR), $(MAKE_SOURCE_DIR), or $(RULES_SOURCE_DIR)."; \
	else \
		echo "Pro command sources detected: $(words $(PRO_COMMAND_FILES))"; \
		echo "Make command sources detected: $(words $(MAKE_COMMAND_FILES))"; \
		echo "Rules command sources detected: $(words $(RULES_COMMAND_FILES))"; \
	fi
	@for source in $(PRO_COMMAND_FILES); do \
		if [[ -f "$(PRO_SOURCE_DIR)/$$source" ]]; then \
			echo "Source file OK: $(PRO_SOURCE_DIR)/$$source"; \
		else \
			echo "Source file missing: $(PRO_SOURCE_DIR)/$$source"; \
		fi; \
	done
	@for source in $(MAKE_COMMAND_FILES); do \
		if [[ -f "$(MAKE_SOURCE_DIR)/$$source" ]]; then \
			echo "Source file OK: $(MAKE_SOURCE_DIR)/$$source"; \
		else \
			echo "Source file missing: $(MAKE_SOURCE_DIR)/$$source"; \
		fi; \
	done
	@for source in $(RULES_COMMAND_FILES); do \
		if [[ -f "$(RULES_SOURCE_DIR)/$$source" ]]; then \
			echo "Source file OK: $(RULES_SOURCE_DIR)/$$source"; \
		else \
			echo "Source file missing: $(RULES_SOURCE_DIR)/$$source"; \
		fi; \
	done
	@for entry in $(PRO_COLON_COMMAND_NAMES); do \
		path="$(COMMANDS_DIR)/$$entry"; \
		if [[ -L "$$path" ]]; then \
			echo "Colon link: $$path -> $$(readlink "$$path")"; \
		elif [[ -e "$$path" ]]; then \
			echo "Colon path exists (not symlink): $$path"; \
		else \
			echo "Colon link missing: $$path"; \
		fi; \
	done
	@for entry in $(MAKE_COMMAND_NAMES); do \
		path="$(COMMANDS_DIR)/$$entry"; \
		if [[ -L "$$path" ]]; then \
			echo "Make link: $$path -> $$(readlink "$$path")"; \
		elif [[ -e "$$path" ]]; then \
			echo "Make path exists (not symlink): $$path"; \
		else \
			echo "Make link missing: $$path"; \
		fi; \
	done
	@for entry in $(RULES_COMMAND_NAMES); do \
		path="$(COMMANDS_DIR)/$$entry"; \
		if [[ -L "$$path" ]]; then \
			echo "Rules link: $$path -> $$(readlink "$$path")"; \
		elif [[ -e "$$path" ]]; then \
			echo "Rules path exists (not symlink): $$path"; \
		else \
			echo "Rules link missing: $$path"; \
		fi; \
	done
	@if [[ -L "$(AGENTS_LINK)" ]]; then \
		echo "AGENTS.md link: $(AGENTS_LINK) -> $$(readlink "$(AGENTS_LINK)")"; \
	elif [[ -e "$(AGENTS_LINK)" ]]; then \
		echo "AGENTS.md exists (not symlink): $(AGENTS_LINK)"; \
	else \
		echo "AGENTS.md link missing: $(AGENTS_LINK)"; \
	fi
	@for label in \
		"Handoff plugin|$(PRO_HANDOFF_PLUGIN_LINK)" \
		"Plan safety plugin|$(PLAN_SAFETY_PLUGIN_LINK)" \
	; do \
		name="$${label%%|*}"; \
		path="$${label#*|}"; \
		if [[ -L "$$path" ]]; then \
			echo "$$name link: $$path -> $$(readlink "$$path")"; \
		elif [[ -e "$$path" ]]; then \
			echo "$$name path exists (not symlink): $$path"; \
		else \
			echo "$$name link missing: $$path"; \
		fi; \
	done

enable-plan-safety: ## Apply Plan-by-default safety rails to global config
	@node bin/enable-plan-safety.mjs

doctor: ## Validate repo and command source prerequisites
	@for path in "$(ROOT_DIR)" "$(OPENCODE_DIR)" "$(PRO_SOURCE_DIR)" "$(MAKE_SOURCE_DIR)" "$(RULES_SOURCE_DIR)"; do \
		if [[ ! -e "$$path" ]]; then \
			echo "Error: required path missing: $$path"; \
			exit 1; \
		fi; \
	done
	@if [[ -z "$(PRO_COMMAND_FILES)" && -z "$(MAKE_COMMAND_FILES)" && -z "$(RULES_COMMAND_FILES)" ]]; then \
		echo "Error: no command files found under $(PRO_SOURCE_DIR), $(MAKE_SOURCE_DIR), or $(RULES_SOURCE_DIR)."; \
		exit 1; \
	fi
	@for source in $(PRO_COMMAND_FILES); do \
		if [[ ! -f "$(PRO_SOURCE_DIR)/$$source" ]]; then \
			echo "Error: missing command file: $(PRO_SOURCE_DIR)/$$source"; \
			exit 1; \
		fi; \
	done
	@for source in $(MAKE_COMMAND_FILES); do \
		if [[ ! -f "$(MAKE_SOURCE_DIR)/$$source" ]]; then \
			echo "Error: missing command file: $(MAKE_SOURCE_DIR)/$$source"; \
			exit 1; \
		fi; \
	done
	@for source in $(RULES_COMMAND_FILES); do \
		if [[ ! -f "$(RULES_SOURCE_DIR)/$$source" ]]; then \
			echo "Error: missing command file: $(RULES_SOURCE_DIR)/$$source"; \
			exit 1; \
		fi; \
	done
	@echo "Doctor checks passed."

test: ## Run local unit tests
	@node --test test/*.test.mjs
