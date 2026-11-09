.PHONY: fmt fmt-check validate help

help:
	@echo "make fmt         format HCL"
	@echo "make fmt-check   CI-style format check"
	@echo "make validate    offline validate for stacks/dev"

fmt:
	terraform fmt -recursive .

fmt-check:
	terraform fmt -check -recursive .

validate:
	bash scripts/validate.sh
