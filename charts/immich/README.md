# Immich Helm Chart

This Helm chart deploys Immich, a high performance self-hosted photo and video management solution.

## Prerequisites

- Kubernetes 1.20+
- Helm 3.0+
- CloudNativePG operator must be installed in the cluster (for database management)

## Installing the CloudNativePG Operator

If you don't have the CloudNativePG operator installed:

```bash
kubectl apply -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.24/releases/cnpg-1.24.1.yaml
```

## Installation

```bash
helm install immich ./immich
```

## Configuration

See `values.yaml` for configuration options.

### Database Configuration

This chart uses CloudNativePG to deploy a PostgreSQL database with the vectorchord extension required by Immich. The database is automatically configured with the necessary extensions.

Key database configuration options:
- `database.enabled`: Enable/disable the CloudNativePG database (default: true)
- `database.instances`: Number of PostgreSQL replicas (default: 1)
- `database.storage.size`: Storage size for the database (default: 10Gi)
- `database.image.repository`: PostgreSQL image with vectorchord extension

If you want to use an external database, set `database.enabled: false` and configure the database connection via the `env` section.

### Storage

You need to configure persistent storage for Immich's library:
- `persistence.library.enabled`: Enable persistent storage (default: true)
- `persistence.library.size`: Storage size (default: 10Gi)
- `persistence.library.existingClaim`: Use an existing PVC (optional)
