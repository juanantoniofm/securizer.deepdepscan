help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: help run apply destroy 

apply: ## Apply the terraform stuff
	TF_LOG=TRACE terraform apply -auto-approve 2> debug.log

destroy: ## Destroy the terraform stack
	terraform destroy -auto-approve

init:  ## do stuff to initialize the terraform
	terraform init # i guess
	terraform import aws_key_pair.wakawaka
	@echo "Enter the details for the git ssh that will be used to pull repos"
	ssh-keygen -t rsa -q -f .secrets/git_ssh_key
	@echo "Enter the details (no password is recomended) for the git deploy ssh key"
	ssh-keygen -t rsa -q -f .secrets/git_ssh_key

manual-provision:
	@echo "When everything fails, provision manually"
	@scp provision.sh ubuntu@$(shell cat ip_address.txt):/tmp/script.sh
	@scp .secrets/git_ssh_key ubuntu@$(shell cat ip_address.txt):~/.ssh/id_rsa
	@scp .secrets/git_ssh_key.pub ubuntu@$(shell cat ip_address.txt):~/.ssh/id_rsa.pub
	@ssh ubuntu@$(shell cat ip_address.txt) bash -x /tmp/script.sh

