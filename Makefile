.PHONY: help init plan apply destroy validate fmt lint kubeconfig verify clean

CLUSTER_NAME ?= eks-production-platform
AWS_REGION ?= us-east-1

help:
	@echo "AWS EKS Production Platform — CLI automation"
	@echo ""
	@echo "  make init        - Initialize Terraform working directory"
	@echo "  make fmt         - Check & format Terraform code"
	@echo "  make validate    - Validate Terraform configurations"
	@echo "  make plan        - Generate and view Terraform execution plan"
	@echo "  make apply       - Apply Terraform infrastructure"
	@echo "  make destroy     - Tear down all AWS resources safely"
	@echo "  make kubeconfig  - Update local kubeconfig to point to EKS cluster"
	@echo "  make verify      - Run automated cluster validation & health check script"
	@echo "  make clean       - Clean local build & terraform state caches"

init:
	cd terraform && terraform init

fmt:
	cd terraform && terraform fmt -recursive

validate: fmt
	cd terraform && terraform validate

plan: validate
	cd terraform && terraform plan -var-file=terraform.tfvars

apply: validate
	cd terraform && terraform apply -var-file=terraform.tfvars -auto-approve

destroy:
	cd terraform && terraform destroy -var-file=terraform.tfvars

kubeconfig:
	aws eks update-kubeconfig --region $(AWS_REGION) --name $(CLUSTER_NAME)

verify:
	bash scripts/validate_cluster.sh

clean:
	rm -rf terraform/.terraform terraform/*.tfstate* terraform/.terraform.lock.hcl
