# ESO Trusted Profile Module (AWS IRSA)

This module creates and configures an **AWS IAM Role** to authenticate with the **External Secrets Operator (ESO)** via **IRSA (IAM Roles for Service Accounts)** in EKS.

It allows a **specific ServiceAccount in a specific namespace** to assume the role and read secrets from **AWS Secrets Manager**, optionally scoped to a list of secret ARNs (originally IBM secret groups).  

> This is a refactor of the original IBM Trusted Profile module to work on AWS using native IAM/IRSA primitives.

---

## Architecture Comparison

```
IBM Cloud Trusted Profile              AWS IRSA (EKS)

+------------------------+            +------------------------+
| IBM Trusted Profile    |            | AWS IAM Role           |
| - Identity container   |            | - Identity container   |
+------------------------+            +------------------------+
           |                                   |
           | Claim Rule (SA + NS + CRN)        | OIDC trust policy
           v                                   v
+------------------------+            +------------------------+
| Profile Policy         |            | IAM Policy             |
| - Secrets Manager      |            | - Secrets Manager ARNs |
| - Secret Groups        |            | - Least privilege      |
+------------------------+            +------------------------+
           |                                   |
           v                                   v
+------------------------+            +------------------------+
| Kubernetes Pod         |            | Kubernetes Pod         |
| - Uses CRI token       |            | - Uses IRSA token      |
| - ESO reads secrets    |            | - ESO reads secrets    |
+------------------------+            +------------------------+
```

---

## Usage

```hcl
module "clusterstore_trusted_profile" {
  source = "git::https://github.com/aot-technologies/terraform-aws-external-secrets-operator.git//modules/eso-trusted-profile?ref=main"

  # Required
  trusted_profile_name            = local.cstore_trusted_profile_name
  secrets_manager_arns                = [module.tp_clusterstore_secrets_manager_group.secret_group_arns]
  tp_cluster_crn                  = module.eks_cluster.oidc_provider_arn
  tp_namespace                    = var.eso_namespace
}
```

---

### Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.0 |
| aws       | >= 5.0 |
| kubernetes | >= 2.0 |

---

### Modules

No modules.

---

### Resources

| Name | Type |
|------|------|
| [aws_iam_role.trusted_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_policy.secrets_reader_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.secrets_reader_scoped](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.attach_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.attach_scoped](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [kubernetes_service_account.external_secrets](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |

---

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| trusted_profile_name | The name of the IAM Role (analogous to IBM Trusted Profile). | `string` | n/a | yes |
| secrets_manager_arns | List of secret ARNs (analogous to IBM secret groups) to restrict access. | `list(string)` | `[]` | no |
| tp_cluster_crn | EKS OIDC provider ARN used for IRSA trust. | `string` | n/a | yes |
| tp_namespace | Kubernetes namespace of the ServiceAccount to bind the role. | `string` | n/a | yes |

---

### Outputs

| Name | Description |
|------|-------------|
| trusted_profile_id | ARN of the IAM Role created for ESO. |
| trusted_profile_name | Name of the IAM Role. |

---

### Notes

- The ServiceAccount is annotated with the IAM Role ARN, enabling **IRSA**.
- Least-privilege is enforced by scoping secrets access via `secrets_manager_arns` (or unrestricted if empty).

