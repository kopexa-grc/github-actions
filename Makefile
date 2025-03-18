prep: ## Install tools
	go install github.com/hashicorp/copywrite@latest

license: license/headers/check

license/headers/check:
	copywrite headers --plan

license/headers/apply:
	copywrite headers
