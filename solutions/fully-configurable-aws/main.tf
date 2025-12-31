
############################
# ESO Namespace
############################
resource "kubernetes_namespace" "eso" {
  metadata {
    name = var.eso_namespace
  }
}

############################
# Deploy External Secrets Operator
############################
module "eso_external_secret" {
  source               = "../../modules/eso-external-secret"
  namespace            = var.eso_namespace
  service_account_name = "external-secrets" # must match trusted-profile SA
  chart_version        = "0.10.1"
}

############################
# Cluster-level Trusted Profile + ClusterSecretStore
############################
module "eso_trusted_profile_cluster" {
  source               = "../../modules/eso-trusted-profile"
  trusted_profile_name = "eso-cluster-role"
  tp_namespace         = var.eso_namespace
  tp_cluster_crn       = var.eks_oidc_provider_arn
  secrets_manager_arns = var.cluster_secret_arns
}

module "eso_clusterstore" {
  source     = "../../modules/eso-clusterstore"
  name       = "cluster-aws-sm"
  namespace  = var.eso_namespace
  aws_region = var.aws_region
  sa_name    = module.eso_trusted_profile_cluster.external_secrets_sa_name
}

############################
# Tenant-level Trusted Profiles + SecretStores
############################
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

