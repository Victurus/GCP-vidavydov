DIR=$(shell pwd)

all: run_ntab
	clear

run_ntab:
	tmux send-keys -t .+ " cd $(DIR);clear;terraform validate" 'Enter'

test:
	cd $(DIR);clear;terraform plan

test_ntab:
	tmux send-keys -t .+ " cd $(DIR);clear;terraform plan" 'Enter'

.PHONY: run_ntab
