variable "trusted_profile_name" {
  type        = string
  description = "The name of the trusted profile to be used. This allows ESO to use CRI based authentication to access secrets manager. The trusted profile must be created in advance"
}


variable "secrets_manager_arns" {
  type        = list(string)
  description = "The list of secrets arns (files) to limit access to for the trusted profile to create."
  default     = []
}

variable "tp_cluster_crn" {
  type        = string
  description = "Target cluster CRN for the trusted profile. Used when creating trusted profile"
}


variable "tp_namespace" {
  description = "Namespace to configure in the Trusted Profile on IAM. Its value must be the namespace where the operator is deployed and running."
  type        = string
}
