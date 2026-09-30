variable "aws_region" {
  description = "AWS region for cluster deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Target deployment environment"
  type        = string
  default     = "production"
}

variable "cluster_name" {
  description = "Name of the Amazon EKS cluster"
  type        = string
  default     = "eks-production-platform"
}

variable "cluster_version" {
  description = "Kubernetes control plane version"
  type        = string
  default     = "1.30"
}

variable "vpc_cidr" {
  description = "CIDR block for the dedicated VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of Availability Zones for multi-AZ topology"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private application workloads"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public ingress ALBs"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "karpenter_version" {
  description = "Karpenter helm release version"
  type        = string
  default     = "0.37.0"
}

variable "argocd_version" {
  description = "ArgoCD helm release version"
  type        = string
  default     = "6.7.18"
}
