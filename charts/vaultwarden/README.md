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
database:
  mode: standalone
```

### Cluster Mode

Deploys a PostgreSQL cluster using CloudNativePG operator for high availability.

```yaml
database:
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
database:
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
database:
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
| `database.mode` | Database mode: standalone, cluster, or external | `standalone` |
| `database.username` | PostgreSQL username | `vaultwarden` |
| `database.database` | PostgreSQL database name | `vaultwarden` |
| `database.password.value` | Direct password value (creates secret) | `""` |
| `database.password.secretName` | Use existing secret for password | `""` |
| `database.cluster.instances` | Number of PostgreSQL instances (cluster mode) | `2` |
| `database.cluster.persistence.size` | Persistent volume size for database | `512Mi` |
| `database.external.host` | External PostgreSQL hostname | `""` |
| `database.external.port` | External PostgreSQL port | `5432` |
| `database.backup.enabled` | Enable scheduled backups | `false` |
| `database.backup.cron` | Backup schedule (cron format) | `"0 2 * * *"` |
| `database.backup.retention` | Number of backups to retain | `30` |

