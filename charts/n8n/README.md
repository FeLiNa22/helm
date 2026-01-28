# n8n

n8n is a fair-code licensed workflow automation tool. It can be used to automate tasks, connect to APIs, and more.

## TL;DR

```console
helm repo add raulpatel https://charts.raulpatel.com
helm install n8n raulpatel/n8n
```

## Introduction

This chart deploys n8n workflow automation on a Kubernetes cluster using the Helm package manager.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)

## Installing the Chart

To install the chart with the release name `n8n`:

```console
helm install n8n raulpatel/n8n
```

The command deploys n8n on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `n8n` deployment:

```console
helm delete n8n
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

### Image parameters

| Name | Description | Value |
| --- | --- | --- |
| `image.repository` | The Docker repository to pull the image from. | `n8nio/n8n` |
| `image.tag` | The image tag to use. | `latest` |
| `image.pullPolicy` | The logic of image pulling. | `IfNotPresent` |
| `image.autoupdate.enabled` | Enable automatic image updates via ArgoCD Image Updater. | `false` |
| `image.autoupdate.strategy` | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest). | `""` |
| `image.autoupdate.allowTags` | Match function for allowed tags (e.g., "regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$" or "any"). | `""` |
| `image.autoupdate.ignoreTags` | List of glob patterns to ignore specific tags. | `[]` |
| `image.autoupdate.pullSecret` | Reference to secret for private registry authentication. | `""` |
| `image.autoupdate.platforms` | List of target platforms (e.g., ["linux/amd64", "linux/arm64"]). | `[]` |

### Deployment parameters

| Name | Description | Value |
| --- | --- | --- |
| `replicaCount` | The number of replicas to deploy. | `1` |
| `n8n.protocol` | Protocol for n8n (http/https). | `http` |
| `n8n.port` | Port on which n8n will run. | `5678` |
| `n8n.startCommand` | Command to start n8n (default includes sleep delay). | `sleep 5; n8n start` |
| `n8n.persistence.enabled` | Whether to enable persistence for n8n data. | `true` |
| `n8n.persistence.storageClass` | The storage class to use for persistence. | `""` |
| `n8n.persistence.size` | Size of the persistence volume. | `10Gi` |
| `n8n.persistence.existingClaim` | Use an existing PVC instead of creating a new one. | `""` |
| `n8n.persistence.mountPath` | Mount path for n8n data. | `/home/node/.n8n` |
| `n8n.initContainer.enabled` | Whether to enable the init container for volume permissions. | `true` |
| `n8n.initContainer.image` | Image for the init container. | `busybox` |
| `n8n.initContainer.tag` | Tag for the init container image. | `1.36` |
| `n8n.resources` | Resource limits and requests for n8n container. | `{"requests":{"memory":"250Mi"},"limits":{"memory":"500Mi"}}` |
| `n8n.nodeSelector` | Optional node selector to use. | `{}` |
| `n8n.tolerations` | Whether to set node tolerations. | `[]` |
| `n8n.affinity` | Whether to set node affinity. | `{}` |

### Environment Variables

| Name | Description | Value |
| --- | --- | --- |
| `env` | Environment variables for n8n (use map format: key: value). | `{}` |

### Service parameters

| Name | Description | Value |
| --- | --- | --- |
| `service.type` | The type of service to create. | `ClusterIP` |
| `service.port` | The port on which the service will run. | `80` |

### Ingress parameters

| Name | Description | Value |
| --- | --- | --- |
| `ingress.enabled` | Whether to enable the ingress. | `false` |
| `ingress.className` | The ingress class name to use. | `""` |
| `ingress.annotations` | Annotations for the Ingress resource. | `{}` |
| `ingress.tls.enabled` | Enable TLS for the Ingress. | `false` |
| `ingress.tls.hosts` | List of hosts for which the TLS certificate is valid. | `[]` |
| `ingress.hosts[0].host` | The host name that the Ingress will respond to. | `n8n.local` |
| `ingress.hosts[0].paths[0].path` | URL path for the HTTP rule. | `/` |
| `ingress.hosts[0].paths[0].pathType` | Type of path matching. | `Prefix` |

### Database parameters

PostgreSQL database is required for n8n

| Name | Description | Value |
| --- | --- | --- |
| `database.mode` | The mode of PostgreSQL deployment: 'standalone', 'cluster', or 'external'. | `standalone` |
| `database.type` | Database type (postgresdb, postgres, mysql, mariadb, sqlite). | `postgresdb` |

#### Standalone PostgreSQL

| Name | Description | Value |
| --- | --- | --- |
| `database.standalone.image.repository` | PostgreSQL image repository. | `postgres` |
| `database.standalone.image.tag` | PostgreSQL image tag. | `16-alpine` |
| `database.standalone.auth.database` | Name of the database to create. | `n8n` |
| `database.standalone.auth.username` | Username for the database. | `n8n` |
| `database.standalone.auth.password` | Password for the database user (leave empty to auto-generate). | `""` |
| `database.standalone.auth.existingSecret` | Reference to an existing Kubernetes secret for auth. | `""` |
| `database.standalone.persistence.enabled` | Whether to enable persistence for standalone PostgreSQL. | `true` |
| `database.standalone.persistence.size` | Size of the persistence volume. | `10Gi` |
| `database.standalone.persistence.storageClass` | Storage class for persistence. | `""` |
| `database.standalone.resources` | Resource limits and requests for standalone PostgreSQL. | `{}` |

#### Cluster PostgreSQL (CloudNativePG)

| Name | Description | Value |
| --- | --- | --- |
| `database.cluster.name` | Name of the database cluster. | `n8n-db` |
| `database.cluster.instances` | Number of PostgreSQL instances (replicas). | `2` |
| `database.cluster.image.repository` | PostgreSQL container image repository. | `ghcr.io/cloudnative-pg/postgresql` |
| `database.cluster.image.tag` | PostgreSQL container image tag. | `16` |
| `database.cluster.database` | Name of the database to create. | `n8n` |
| `database.cluster.owner` | Owner of the database. | `n8n` |
| `database.cluster.storage.size` | Size of the storage for each instance. | `10Gi` |
| `database.cluster.storage.storageClass` | Storage class name for persistent volumes. | `""` |
| `database.cluster.secret.name` | Name of the secret containing database credentials. | `""` |
| `database.cluster.secret.create` | Whether to create the database secret. | `true` |
| `database.cluster.secret.username` | Database user username. | `n8n` |
| `database.cluster.secret.password` | Database user password (leave empty to auto-generate). | `""` |
| `database.cluster.superuserSecret.name` | Name of the secret containing the superuser credentials. | `""` |
| `database.cluster.superuserSecret.create` | Whether to create the superuser secret. | `true` |
| `database.cluster.superuserSecret.username` | Superuser username. | `postgres` |
| `database.cluster.superuserSecret.password` | Superuser password (leave empty to auto-generate). | `""` |

#### External PostgreSQL

| Name | Description | Value |
| --- | --- | --- |
| `database.external.host` | Hostname of external PostgreSQL (when mode is 'external'). | `""` |
| `database.external.port` | Port of external PostgreSQL. | `5432` |
| `database.external.database` | Database name of external PostgreSQL. | `n8n` |
| `database.external.username` | Username of external PostgreSQL. | `n8n` |
| `database.external.existingSecret` | Secret name for external PostgreSQL password. | `""` |
| `database.external.secretKey` | Key in the secret for the password. | `password` |

### ArgoCD Image Updater parameters

| Name | Description | Value |
| --- | --- | --- |
| `imageUpdater.namespace` | Namespace where the ImageUpdater CRD will be created. | `argocd` |
| `imageUpdater.argocdNamespace` | Namespace where ArgoCD Applications are located. | `argocd` |
| `imageUpdater.applicationName` | Name or pattern of the ArgoCD Application to update. Defaults to Release name. | `""` |
| `imageUpdater.imageAlias` | Alias for the image in the ImageUpdater CRD. Defaults to Release name. | `""` |
| `imageUpdater.forceUpdate` | Force update even if image is not currently deployed. | `false` |
| `imageUpdater.helm` | Helm-specific configuration for parameter names (e.g., {name: "image.repository", tag: "image.tag"}). | `{}` |
| `imageUpdater.kustomize` | Kustomize-specific configuration (e.g., {name: "original/image"}). | `{}` |
| `imageUpdater.writeBackConfig` | Write-back configuration for GitOps. | `{}` |

## Configuration Examples

### Using Standalone PostgreSQL (Default)

```yaml
database:
  mode: standalone
  standalone:
    persistence:
      enabled: true
      size: 10Gi
```

### Using External PostgreSQL

```yaml
database:
  mode: external
  external:
    host: my-postgres.example.com
    port: 5432
    database: n8n
    username: n8n
    existingSecret: my-postgres-secret
    secretKey: password
```

### Using CloudNativePG Cluster

```yaml
database:
  mode: cluster
  cluster:
    instances: 3
    storage:
      size: 20Gi
```

### Adding Custom Environment Variables

```yaml
env:
  GENERIC_TIMEZONE: "America/New_York"
  N8N_METRICS: "true"
  EXECUTIONS_PROCESS: "main"
```

## License

This chart is licensed under the Apache 2.0 license.
