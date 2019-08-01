help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: help run apply destroy 

init:  ## Ensure a working ansible environment
	ansible-playbook --version

run:  ## Provision the infrastructure with the latest code
	ansible-playboox -i hosts workstation.yml
