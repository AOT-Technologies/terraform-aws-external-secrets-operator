
############################
# ESO Namespace
############################
resource "kubernetes_namespace" "eso" {
  metadata {
    name = var.eso_namespace
  }
}

############################
# Cluster-level Trusted Profile + ClusterSecretStore + External-Secrets
############################
module "eso_trusted_profile_cluster" {
  source               = "../../modules/eso-trusted-profile"
  trusted_profile_name = "eso-cluster-role"
  tp_namespace         = var.eso_namespace
  tp_cluster_crn       = var.eks_oidc_provider_arn
  secrets_manager_arns = var.cluster_secret_arns
}

module "eso_external_secrets_cluster" {
  source = "github.com/AOT-Technologies/terraform-aws-external-secrets-operator//modules/eso-external-secret"

  # --- Kubernetes ---
  es_kubernetes_namespace     = "external-secrets"
  es_kubernetes_secret_name   = "external-secrets"
  es_kubernetes_secret_type   = "opaque"

  # --- External Secrets Operator ---
  eso_store_name              = "aws-secret-store"
  eso_store_kind              = "ClusterSecretStore"
  es_refresh_interval         = "1h"

  # --- AWS Secrets Manager ---
  sm_secret_type              = "kv"
  sm_secret_id                = "external-secrets"

  # Pull ALL keys from the JSON
  sm_secret_property          = null

  # Optional but common
  creation_policy             = "Owner"
  deletion_policy             = "Delete"
  reloader_watching            = true
}

module "eso_clusterstore" {
  source                              = "../../modules/eso-clusterstore"
  
  region                              = var.region
  eso_authentication                  = "aws_irsa"
  eso_namespace                       = "external-secrets"
  clusterstore_secret_name            = "external-secrets"
}

############################
# Tenant-level Trusted Profiles + SecretStores + External-Secrets
############################
module "eso_external_secrets_tenant" {
  for_each                    = var.secretstores
  source = "github.com/AOT-Technologies/terraform-aws-external-secrets-operator//modules/eso-external-secret"

  # --- Kubernetes ---
  es_kubernetes_namespace     = each.value.namespace
  es_kubernetes_secret_name   = each.value.namespace
  es_kubernetes_secret_type   = "opaque"

  # --- External Secrets Operator ---
  eso_store_name              = "aws-secret-store"
  eso_store_kind              = "ClusterSecretStore"
  es_refresh_interval         = "1h"

  # --- AWS Secrets Manager ---
  sm_secret_type              = "kv"
  sm_secret_id                = each.value.namespace

  # Pull ALL keys from the JSON
  sm_secret_property          = null

  # Optional but common
  creation_policy             = "Owner"
  deletion_policy             = "Delete"
  reloader_watching            = true
}

module "eso_trusted_profile_tenant" {
  for_each             = var.secretstores
  source               = "../../modules/eso-trusted-profile"
  trusted_profile_name = "eso-${each.key}-role"
  tp_namespace         = each.value.namespace
  tp_cluster_crn       = var.eks_oidc_provider_arn
  secrets_manager_arns = each.value.secrets_manager_arns
}

module "eso_secretstore" {
  for_each   = var.secretstores
  source     = "../../modules/eso-secretstore"
  name       = "tenant-${each.key}-aws-sm"
  namespace  = each.value.namespace
  aws_region = var.aws_region
  sa_name    = module.eso_trusted_profile_tenant[each.key].external_secrets_sa_name
}

