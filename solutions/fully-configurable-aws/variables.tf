############################
# EKS / OIDC
############################
variable "eks_oidc_provider_arn" {
  description = "The ARN of the EKS OIDC provider (for IRSA)."
  type        = string
}

variable "region" {
  description = "Region where secrets exist and resources will be created."
  type        = string
  default     = "ca-central-1"
}

############################
# ESO Operator
############################
variable "eso_namespace" {
  description = "Namespace where External Secrets Operator is deployed."
  type        = string
  default     = "external-secrets"
}

############################
# Cluster-level Secrets
############################
variable "cluster_secret_arns" {
  description = "Optional list of AWS Secrets Manager ARNs for cluster-level secrets."
  type        = list(string)
  default     = []
}

############################
# Tenant-level Secrets
############################
variable "secretstores" {
  description = <<EOT
Map of tenant/namespace-specific secret stores.  

Each entry should include:
- namespace: Kubernetes namespace where secrets should be available
- secrets_manager_arns: List of AWS Secrets Manager ARNs to grant access
EOT
  type = map(object({
    namespace            = string
    secrets_manager_arns = list(string)
  }))
  default = {}
}

