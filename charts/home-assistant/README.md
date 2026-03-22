# Home Assistant Helm Chart

This Helm chart deploys [Home Assistant](https://www.home-assistant.io/) on Kubernetes using the upstream [pajikos/home-assistant-helm-chart](https://github.com/pajikos/home-assistant-helm-chart) as a dependency, with an optional [PostgreSQL](https://www.postgresql.org/) database managed by the local `postgres` chart.

## Prerequisites

- Kubernetes 1.20+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (for persistence)
- CloudNativePG operator (if using `postgres.mode: cluster`)

## Installation

```bash
# Update dependencies
helm dependency update ./home-assistant

# Install the chart with a postgres password
helm install home-assistant ./home-assistant \
  --set postgres.password.value=mysecretpassword \
  --set homeassistant.postgres.password=mysecretpassword
```

## Architecture

This chart deploys the following components:

1. **Home Assistant** – The main application server (via upstream `pajikos/home-assistant` subchart)
2. **PostgreSQL** – Database for Home Assistant's recorder integration (via local `postgres` subchart)

Home Assistant's recorder integration is automatically configured to use the PostgreSQL instance deployed by the postgres subchart.

## Database Configuration

The chart supports three PostgreSQL deployment modes via `postgres.mode`:

- **standalone** (default): Simple StatefulSet deployment for home server use
- **cluster**: CloudNativePG operator for high-availability (requires CNPG operator)
- **external**: Connect to an existing PostgreSQL instance

> **Note:** `postgres.password.value` and `homeassistant.postgres.password` must be set to the same value. The former creates the PostgreSQL secret; the latter is used to construct the `recorder.db_url` in Home Assistant's `configuration.yaml`.

## Parameters

### PostgreSQL parameters

| Name | Description | Value |
| ---- | ----------- | ----- |
| `postgres.enabled` | Whether to deploy the PostgreSQL dependency. | `true` |
| `postgres.mode` | Deployment mode: `standalone`, `cluster`, or `external`. | `standalone` |
| `postgres.username` | PostgreSQL username. | `homeassistant` |
| `postgres.database` | PostgreSQL database name. | `homeassistant` |
| `postgres.password.value` | Plain-text password. Creates a Secret when set. | `""` |
| `postgres.password.secretName` | Name of an existing secret containing the password. | `""` |
| `postgres.standalone.image.repository` | Docker image repository for standalone PostgreSQL. | `postgres` |
| `postgres.standalone.image.tag` | Docker image tag for standalone PostgreSQL. | `16-alpine` |
| `postgres.standalone.persistence.enabled` | Enable persistent storage for standalone PostgreSQL. | `true` |
| `postgres.standalone.persistence.size` | Size of the persistent volume. | `512Mi` |
| `postgres.standalone.persistence.storageClass` | Storage class for the persistent volume. | `""` |
| `postgres.cluster.instances` | Number of PostgreSQL instances in the CloudNativePG cluster. | `2` |
| `postgres.cluster.image.repository` | Docker image repository for CloudNativePG cluster. | `ghcr.io/cloudnative-pg/postgresql` |
| `postgres.cluster.image.tag` | Docker image tag for CloudNativePG cluster. | `16` |
| `postgres.cluster.persistence.size` | Size of the persistent volume for each cluster instance. | `512Mi` |
| `postgres.cluster.persistence.storageClass` | Storage class for the persistent volume. | `""` |
| `postgres.external.host` | Hostname of the external PostgreSQL instance. | `""` |
| `postgres.external.port` | Port of the external PostgreSQL instance. | `5432` |

### Home Assistant parameters

| Name | Description | Value |
| ---- | ----------- | ----- |
| `homeassistant.enabled` | Whether to deploy the Home Assistant dependency. | `true` |
| `homeassistant.image.repository` | Docker image repository. | `ghcr.io/home-assistant/home-assistant` |
| `homeassistant.image.tag` | Docker image tag. | `2026.3.3` |
| `homeassistant.image.pullPolicy` | Image pull policy. | `IfNotPresent` |
| `homeassistant.image.autoupdate.enabled` | Enable automatic image updates via ArgoCD Image Updater. | `false` |
| `homeassistant.image.autoupdate.strategy` | Strategy for image updates (semver, latest, newest-build, name, alphabetical, digest). | `""` |
| `homeassistant.image.autoupdate.allowTags` | Match function for allowed tags. | `""` |
| `homeassistant.image.autoupdate.ignoreTags` | List of glob patterns to ignore specific tags. | `[]` |
| `homeassistant.image.autoupdate.pullSecret` | Reference to secret for private registry authentication. | `""` |
| `homeassistant.image.autoupdate.platforms` | List of target platforms. | `[]` |
| `homeassistant.controller.type` | Controller type: `Deployment` or `StatefulSet`. | `Deployment` |
| `homeassistant.deploymentStrategy` | Deployment strategy (`RollingUpdate` or `Recreate`). | `Recreate` |
| `homeassistant.hostNetwork` | Enable host network mode (required for local device discovery). | `false` |
| `homeassistant.securityContext.privileged` | Run the container in privileged mode. | `true` |
| `homeassistant.service.type` | Service type. | `LoadBalancer` |
| `homeassistant.service.port` | Service port. | `8123` |
| `homeassistant.ingress.enabled` | Whether to create an ingress for the service. | `true` |
| `homeassistant.ingress.className` | Ingress class name. | `""` |
| `homeassistant.ingress.hosts[0].host` | Ingress host. | `chart-example.local` |
| `homeassistant.ingress.hosts[0].paths[0].path` | Ingress path. | `/` |
| `homeassistant.ingress.tls` | Ingress TLS configuration. | `[]` |
| `homeassistant.resources` | CPU/memory resource requests/limits. | `{}` |
| `homeassistant.env` | Environment variables (array format). | `[{name: TZ, value: "Europe/London"}]` |
| `homeassistant.persistence.enabled` | Whether to enable persistence for the Home Assistant config directory. | `true` |
| `homeassistant.persistence.storageClass` | Storage class for the persistent volume claim. | `ceph-rbd` |
| `homeassistant.persistence.existingClaim` | Name of an existing PVC to use. | `""` |
| `homeassistant.persistence.accessMode` | Access mode for the PVC. | `ReadWriteOnce` |
| `homeassistant.persistence.size` | Size of the PVC. | `512Mi` |
| `homeassistant.additionalVolumes` | Additional volumes to add to the pod. | `[]` |
| `homeassistant.additionalMounts` | Additional volume mounts to add to the pod. | `[]` |
| `homeassistant.nodeSelector` | Node selector for the pod. | `{}` |
| `homeassistant.tolerations` | Tolerations for the pod. | `[]` |
| `homeassistant.affinity` | Affinity for the pod. | `{}` |

### Home Assistant postgres connection parameters

These values configure the recorder integration in `configuration.yaml` and must mirror the top-level `postgres` section.

| Name | Description | Value |
| ---- | ----------- | ----- |
| `homeassistant.postgres.mode` | Postgres mode – must match `postgres.mode`. | `standalone` |
| `homeassistant.postgres.username` | Postgres username – must match `postgres.username`. | `homeassistant` |
| `homeassistant.postgres.password` | Postgres password – must match `postgres.password.value`. | `""` |
| `homeassistant.postgres.database` | Postgres database name – must match `postgres.database`. | `homeassistant` |
| `homeassistant.postgres.external.host` | External postgres host (only when `postgres.mode=external`). | `""` |
| `homeassistant.postgres.external.port` | External postgres port (only when `postgres.mode=external`). | `5432` |

### Velero Backup Schedule parameters

| Name | Description | Value |
| ---- | ----------- | ----- |
| `velero.enabled` | Whether to enable Velero backup schedules | `false` |
| `velero.namespace` | Namespace where Velero is deployed | `velero` |
| `velero.schedule` | Cron schedule for Velero backups | `0 2 * * *` |
| `velero.ttl` | Time to live for backups | `168h` |
| `velero.includeClusterResources` | Include cluster-scoped resources in backup | `false` |
| `velero.snapshotVolumes` | Take volume snapshots | `true` |
| `velero.defaultVolumesToFsBackup` | Use file system backup for volumes by default | `false` |
| `velero.storageLocation` | Storage location for backups | `""` |
| `velero.volumeSnapshotLocations` | Volume snapshot locations | `[]` |
| `velero.labelSelector` | Label selector to filter resources | `{}` |
| `velero.annotations` | Additional annotations for Velero Schedule resources | `{}` |

### ArgoCD Image Updater parameters

| Name | Description | Value |
| ---- | ----------- | ----- |
| `imageUpdater.namespace` | Namespace where the ImageUpdater CRD will be created. | `argocd` |
| `imageUpdater.argocdNamespace` | Namespace where ArgoCD Applications are located. | `argocd` |
| `imageUpdater.applicationName` | Name or pattern of the ArgoCD Application to update. Defaults to Release name. | `""` |
| `imageUpdater.imageAlias` | Alias for the image in the ImageUpdater CRD. Defaults to Release name. | `""` |
| `imageUpdater.forceUpdate` | Force update even if image is not currently deployed. | `false` |
| `imageUpdater.helm` | Helm-specific configuration for parameter names. | `{}` |
| `imageUpdater.kustomize` | Kustomize-specific configuration. | `{}` |
| `imageUpdater.writeBackConfig` | Write-back configuration for GitOps. | `{}` |
