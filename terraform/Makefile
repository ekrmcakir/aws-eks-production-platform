.PHONY: help init plan apply destroy validate fmt clean

help:
	@echo "Terraform operations:"
	@echo "  make init      - Initialize Terraform"
	@echo "  make fmt       - Format Terraform code"
	@echo "  make validate  - Validate configurations"
	@echo "  make plan      - Plan Terraform execution"
	@echo "  make apply     - Apply Terraform infrastructure"
	@echo "  make destroy   - Destroy all resources"

init:
	terraform init

fmt:
	terraform fmt

validate: fmt
	terraform validate

plan: validate
	terraform plan -var-file=terraform.tfvars

apply: validate
	terraform apply -var-file=terraform.tfvars -auto-approve

destroy:
	terraform destroy -var-file=terraform.tfvars

clean:
	rm -rf .terraform *.tfstate* .terraform.lock.hcl
