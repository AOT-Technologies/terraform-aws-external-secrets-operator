##################################################################
# ESO deployment
##################################################################
resource "kubernetes_namespace" "eso" {
  metadata {
    name = var.eso_namespace
  }
}

module "external_secrets_operator" {
  source        = "../../"
  eso_namespace = var.eso_namespace
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
  source                        = "../../modules/eso-external-secret"
  eso_store_scope               = "cluster"
  eso_store_name                = "cluster-secret-store"
  es_kubernetes_secret_name     = "external-secrets"
  es_kubernetes_namespace       = "external-secrets"
  es_kubernetes_secret_type     = "opaque"
  es_refresh_interval           = "1h"
  sm_secret_type                = "kv"
  sm_secret_id                  = "external-secrets"
  es_helm_rls_name              = "cluster-externalsecrets"
  es_helm_rls_namespace         = "external-secrets"
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
  for_each                      = var.secretstores
  source                        = "../../modules/eso-external-secret"
  eso_store_scope               = "namespace"
  eso_store_name                = "${each.key}-secretstore"
  es_kubernetes_secret_name     = "${each.key}"
  es_kubernetes_namespace       = "${each.key}"
  es_kubernetes_secret_type     = "opaque"
  es_refresh_interval           = "1h"
  sm_secret_type                = "kv"
  sm_secret_id                  = "${each.key}"
  es_helm_rls_name              = "${each.key}-externalsecrets"
  es_helm_rls_namespace         = "${each.key}"
}

module "eso_trusted_profile_tenant" {
  for_each             = var.secretstores
  source               = "../../modules/eso-trusted-profile"
  trusted_profile_name = "eso-${each.key}-role"
  tp_namespace         = "${each.key}"
  tp_cluster_crn       = var.eks_oidc_provider_arn
  secrets_manager_arns = each.value.secrets_manager_arns
}

module "eso_secretstore" {
  for_each              = var.secretstores
  source                = "../../modules/eso-secretstore"
  region                = var.region
  eso_authentication    = "aws_irsa"
  sstore_secret_name    = "${each.key}"
  sstore_store_name     = "${each.key}-secretstore"
  sstore_namespace      = "${each.key}"
  sstore_helm_rls_name  = "${each.key}-secretstore"
}

