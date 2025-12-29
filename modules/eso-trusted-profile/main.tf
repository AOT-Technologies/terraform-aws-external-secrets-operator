############################
# Locals
############################

locals {
  # IBM module hardcodes ESO SA name in claim rule
  service_account_name = "external-secrets"

  # In AWS, tp_cluster_crn is reinterpreted as the EKS OIDC provider ARN
  # Expected format:
  # arn:aws:iam::<account_id>:oidc-provider/oidc.eks.<region>.amazonaws.com/id/<hash>
  oidc_issuer_host = regex(
    "oidc-provider/(.*)",
    var.tp_cluster_crn
  )[0]
}

############################
# IAM Role (Trusted Profile equivalent)
############################

resource "aws_iam_role" "trusted_profile" {
  name = var.trusted_profile_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.tp_cluster_crn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_issuer_host}:sub" = "system:serviceaccount:${var.tp_namespace}:${local.service_account_name}"
          }
        }
      }
    ]
  })
}

############################################
# IAM Policy — Secrets Manager access
############################################

# Case 1:
# No secrets_manager_arns provided
# → Equivalent to IBM: access to entire Secrets Manager instance
resource "aws_iam_policy" "secrets_reader_all" {
  count = length(var.secrets_manager_arns) == 0 ? 1 : 0

  name = "${var.trusted_profile_name}-secrets-reader-all"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
      }
    ]
  })
}

# Case 2:
# One or more secrets_manager_arns values provided
# → Interpreted as explicit Secrets Manager ARNs or ARN patterns
resource "aws_iam_policy" "secrets_reader_scoped" {
  count = length(var.secrets_manager_arns) > 0 ? 1 : 0

  name = "${var.trusted_profile_name}-secrets-reader-scoped"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.secrets_manager_arns
      }
    ]
  })
}

############################################
# Attach IAM policy to role
############################################

resource "aws_iam_role_policy_attachment" "attach_all" {
  count      = length(var.secrets_manager_arns) == 0 ? 1 : 0
  role       = aws_iam_role.trusted_profile.name
  policy_arn = aws_iam_policy.secrets_reader_all[0].arn
}

resource "aws_iam_role_policy_attachment" "attach_scoped" {
  count      = length(var.secrets_manager_arns) > 0 ? 1 : 0
  role       = aws_iam_role.trusted_profile.name
  policy_arn = aws_iam_policy.secrets_reader_scoped[0].arn
}

############################################
# Kubernetes ServiceAccount (IRSA binding)
############################################

resource "kubernetes_service_account" "external_secrets" {
  metadata {
    name      = local.service_account_name
    namespace = var.tp_namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.trusted_profile.arn
    }
  }
}

