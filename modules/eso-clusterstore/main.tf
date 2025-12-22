locals {
  helm_raw_chart_name    = "raw"
  helm_raw_chart_version = "0.2.5"
}

# define cluster secret store for cluster scope and trusted store auth
# ContainerAuth with CRI based authentication
resource "helm_release" "cluster_secret_store" {
  name      = "${var.clustersecretstore_helm_rls_name}"
  namespace = "${var.eso_namespace}"
  chart     = "${path.module}/../../chart/${local.helm_raw_chart_name}"
  version   = local.helm_raw_chart_version
  timeout   = 600
  values = [
    <<-EOF
    resources:
      - apiVersion: external-secrets.io/v1
        kind: ClusterSecretStore
        metadata:
          name: "${var.clustersecretstore_name}"
        spec:
          provider:
            aws:
              service: SecretsManager
              region: ${var.clustersecretstore_region}
              auth:
                jwt:
                  serviceAccountRef:
                    name: "${var.eso_name}"
                    namespace: "${var.eso_namespace}"
    EOF
  ]
}
