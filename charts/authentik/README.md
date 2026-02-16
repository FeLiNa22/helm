# Authentik Helm Chart

This Helm chart deploys [authentik](https://goauthentik.io/), an open-source Identity Provider focused on flexibility and versatility. It supports SAML, OAuth, OIDC, LDAP, and more.

## Features

- **Server and Worker Deployments**: Separate server and worker components for optimal performance
- **Multiple Database Modes**:
  - **Standalone**: Single PostgreSQL instance using StatefulSet
  - **Cluster**: High-availability PostgreSQL using CloudNativePG operator
  - **External**: Connect to an existing external database
- **Automated Backups**: pg_dump-based database backups with configurable retention
- **Velero Integration**: Full application backup schedules
- **ArgoCD Image Updater**: Automated image updates via GitOps
- **Horizontal Pod Autoscaling**: Scale server and worker pods based on resource utilization
- **Persistent Storage**: Configurable PVCs for media files and databases

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (for persistent storage)

### Optional:
- **CloudNativePG Operator** (for cluster database mode)
- **Velero** (for backup schedules)
- **ArgoCD** (for automated image updates)

## Installation

### Basic Installation (Standalone Mode)

```bash
helm install authentik ./authentik
```

This deploys authentik with:
- Standalone PostgreSQL database
- Persistent storage for media files
- Default configuration

### Custom Installation

```bash
helm install authentik ./authentik \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=authentik.example.com \
  --set postgres.mode=cluster \
  --set postgres.cluster.instances=3
```

## Configuration

### Database Modes

#### Standalone Mode (Default)
Deploys a single PostgreSQL instance using a StatefulSet:

```yaml
postgres:
  mode: standalone
  database: authentik
  username: authentik
  password: ""  # Auto-generated if empty
  persistence:
    enabled: true
    size: 5Gi
  standalone:
    image:
      repository: postgres
      tag: "16-alpine"
    resources: {}
```

#### Cluster Mode (High Availability)
Requires CloudNativePG operator. Deploys a PostgreSQL cluster:

```yaml
postgres:
  mode: cluster
  database: authentik
  username: authentik
  password: ""  # Auto-generated if empty
  cluster:
    name: authentik-db
    instances: 3  # Number of replicas
    image:
      repository: ghcr.io/cloudnative-pg/postgresql
      tag: "16"
    pitrBackup:
      enabled: true
      retentionPolicy: "30d"
      objectStorage:
        destinationPath: "s3://my-bucket/authentik-backups"
        endpointURL: "https://s3.amazonaws.com"
        secretName: "s3-credentials"
        region: "us-east-1"
```

#### External Mode
Connect to an existing database:

```yaml
postgres:
  mode: external
  database: authentik
  username: authentik
  password: "your-password"
  external:
    host: "postgres.example.com"
    port: 5432
  secret:
    name: "authentik-db-secret"  # Optional: use existing secret
    passwordKey: "password"
```

### Ingress Configuration

```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: authentik.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: authentik-tls
      hosts:
        - authentik.example.com
```

### Email Configuration

```yaml
authentik:
  email:
    host: "smtp.gmail.com"
    port: 587
    username: "your-email@gmail.com"
    password: "your-app-password"
    useTLS: true
    useSSL: false
    from: "authentik@example.com"
```

### Automated Backups

#### Database Backups (pg_dump)
```yaml
postgres:
  backup:
    enabled: true
    cron: "0 2 * * *"  # Daily at 2 AM
    retention: 30  # Keep last 30 backups
    persistence:
      enabled: true
      size: 512Mi
```

#### Velero Backup Schedules
```yaml
velero:
  enabled: true
  namespace: "velero"
  schedule: "0 3 * * *"  # Daily at 3 AM
  ttl: "168h"  # 7 days retention
  snapshotVolumes: true
```

### High Availability

```yaml
# Server autoscaling
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80

# Worker autoscaling
worker:
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 5
    targetCPUUtilizationPercentage: 80

# Database cluster
postgres:
  mode: cluster
  cluster:
    instances: 3
```

### Resource Limits

```yaml
resources:
  limits:
    cpu: 2000m
    memory: 4Gi
  requests:
    cpu: 500m
    memory: 1Gi

worker:
  resources:
    limits:
      cpu: 1000m
      memory: 2Gi
    requests:
      cpu: 250m
      memory: 512Mi
```

## Parameters

## Upgrading

### To upgrade the chart:

```bash
helm upgrade authentik ./authentik
```

### Migration from upstream chart

If migrating from the official authentik Helm chart:

1. Export your current values:
   ```bash
   helm get values authentik > old-values.yaml
   ```

2. Map the values to this chart's structure (main differences):
   - Database configuration is under `postgres.*` instead of `postgresql.*`
   - Environment variables use map format instead of array

3. Backup your database before migrating

4. Install this chart with migrated values

## Uninstalling

```bash
helm uninstall authentik
```

This removes all Kubernetes components associated with the chart, except for PVCs (persistent storage). To delete those:

```bash
kubectl delete pvc -l app.kubernetes.io/instance=authentik
```

## Troubleshooting

### Database connection issues

Check database status:
```bash
# Standalone mode
kubectl get statefulset authentik-postgresql
kubectl logs -l app.kubernetes.io/component=database

# Cluster mode
kubectl get cluster
kubectl cnpg status authentik-db
```

### Worker not processing tasks

Check worker logs:
```bash
kubectl logs -l app.kubernetes.io/component=worker
```

### Check authentik configuration

View the current configuration:
```bash
kubectl exec -it deployment/authentik-server -- ak dump_config
```

## Support

- Documentation: https://goauthentik.io/docs/
- GitHub: https://github.com/goauthentik/authentik
- Community: https://github.com/goauthentik/authentik/discussions
