# Vaultwarden Helm Chart

This Helm chart deploys Vaultwarden on Kubernetes.

## Installation

```bash
helm install vaultwarden ./vaultwarden
```

## Configuration

See `values.yaml` for configuration options.

## Database Configuration

Vaultwarden supports three database modes:

### Standalone Mode (Default)

Uses Vaultwarden's built-in SQLite database. No external database is deployed.

```yaml
postgres:
  mode: standalone
```

### Cluster Mode

Deploys a PostgreSQL cluster using CloudNativePG operator for high availability.

```yaml
postgres:
  mode: cluster
  password:
    value: "your-secure-password"  # Or use secretName for existing secret
  cluster:
    instances: 2
    persistence:
      enabled: true
      size: 512Mi
      storageClass: ""
```

### External Mode

Connects to an existing external PostgreSQL database.

```yaml
postgres:
  mode: external
  external:
    host: "postgres.example.com"
    port: 5432
  password:
    value: "your-secure-password"  # Or use secretName for existing secret
```

### Database Backups

Enable scheduled pg_dump backups for cluster and external modes:

```yaml
postgres:
  backup:
    enabled: true
    cron: "0 2 * * *"  # Daily at 2am
    retention: 30  # Keep last 30 backups
    persistence:
      size: 512Mi
```

## Parameters

| Name | Description | Value |
|------|-------------|-------|
| `replicaCount` | Number of replicas | `1` |
| `postgres.mode` | Database mode: standalone, cluster, or external | `standalone` |
| `postgres.username` | PostgreSQL username | `vaultwarden` |
| `postgres.database` | PostgreSQL database name | `vaultwarden` |
| `postgres.password.value` | Direct password value (creates secret) | `""` |
| `postgres.password.secretName` | Use existing secret for password | `""` |
| `postgres.cluster.instances` | Number of PostgreSQL instances (cluster mode) | `2` |
| `postgres.cluster.persistence.size` | Persistent volume size for database (cluster mode) | `512Mi` |
| `postgres.external.host` | External PostgreSQL hostname | `""` |
| `postgres.external.port` | External PostgreSQL port | `5432` |
| `postgres.backup.enabled` | Enable scheduled backups | `false` |
| `postgres.backup.cron` | Backup schedule (cron format) | `"0 2 * * *"` |
| `postgres.backup.retention` | Number of backups to retain | `30` |

