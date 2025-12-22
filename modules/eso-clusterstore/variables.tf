######## eso clusterstore configuration

variable "clustersecretstore_region" {
  description = "Region where Secrets Manager is deployed. It will be used to build the regional URL to the service"
  type        = string
}


variable "clustersecretstore_name" {
  description = "Name of the ESO cluster secrets store to be used/created for cluster scope."
  default     = "cluster-secret-store"
  type        = string
  validation {
    condition     = can(regex("^([a-z][-a-z0-9]*[a-z0-9])$", var.clustersecretstore_name))
    error_message = "The cluster secrets store name must start with a lowercase letter, can contain lowercase letters, numbers and hyphens, and must end with a lowercase letter."
  }
}

variable "clustersecretstore_helm_rls_name" {
  description = "Name of helm release for cluster secrets store"
  type        = string
  default     = "cluster-secret-store"
}

variable "eso_name" {
  description = "Name of the ESO that is deployed. It will be used to deploy the cluster secrets store"
  type        = string
}

variable "eso_namespace" {
  description = "Namespace where the external secrets operator is deployed. It will be used to deploy the cluster secrets store"
  type        = string
}
