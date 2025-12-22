# ESO Cluster Store Module

This module allows to configure an [ClusterSecretStore](https://external-secrets.io/latest/api/clustersecretstore/) resource for an ESO secret store with cluster scope, in the desired namespace (the same of the ESO deploymet is a requirement of ESO and it is up to the consumer) and with the desired configurations.

For more information about ClusterSecretStore resource and about ESO please refer to the ESO documentation available [here](https://external-secrets.io/v0.8.3/guides/introduction/)

This module supports ClusterSecretStore a single configuration to pull/push secrets with the configured Secrets Manager instance:
- via jwt service account authentication

## Usage

```hcl
# Replace "master" with a GIT release version to lock into a specific release
module "eso_clusterstore" {
  source                                    = "git::git@github.com:AOT-Technologies/terraform-aws-external-secrets-operator.git//modules/eso-clusterstore?ref=master"
  clustersecretstore_region                 = "ca-central-1"
  clustersecretstore_helm_rls_name          = "cluster-store"
  clustersecretstore_name                   = "cluster-store"
  eso_name                                  = "external-secrets"
  eso_namespace                             = "external-secrets"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.0.0, <4.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.16.1, <3.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [helm_release.cluster_secret_store](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_clustersecretstore_region"></a> [clustersecretstore\_region](#input\_clustersecretstore\_region) | Region where Secrets Manager is deployed. It will be used to build the regional URL to the service | `string` | n/a | yes |
| <a name="input_clustersecretstore_helm_rls_name"></a> [clustersecretstore\_helm\_rls\_name](#input\_clusterstore\_helm\_rls\_name) | Name of helm release for cluster secrets store | `string` | `"cluster-secret-store"` | no |
| <a name="input_clustersecretstore_name"></a> [clustersecretstore\_name](#input\_clusterstore\_name) | Name of the ESO cluster secrets store to be used/created for cluster scope. | `string` | `"clustersecret-store"` | no |
| <a name="input_eso_name"></a> [eso\_namespace](#input\_eso\_namespace) | Name of the ESO that is deployed. It will be used to deploy the cluster secrets store | `string` | n/a | yes |
| <a name="input_eso_namespace"></a> [eso\_namespace](#input\_eso\_namespace) | Namespace where the ESO is deployed. It will be used to deploy the cluster secrets store | `string` | n/a | yes |

### Outputs
N/A
