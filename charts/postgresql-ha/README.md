# PostgreSQL Cluster Helm Chart

This Helm chart deploys a PostgreSQL cluster using the CloudNativePG (CNPG) operator.

## Features

- High availability PostgreSQL cluster
- Automatic failover
- Point-in-time recovery (PITR)
- Connection pooling with PgBouncer
- Backup and restore capabilities
- Horizontal scaling

## Prerequisites

- Kubernetes 1.20+
- CloudNativePG operator must be installed in the cluster

## Installing the Operator

```bash
kubectl apply -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.24/releases/cnpg-1.24.1.yaml
```

## Installation

```bash
helm install my-postgres ./postgresql-cluster
```

## Configuration

See `values.yaml` for configuration options.

## Connecting to the Database

The chart creates a primary service for read-write operations and a read-only service for read operations:

- Primary (read-write): `<release-name>-rw`
- Read-only: `<release-name>-ro`
- Read service: `<release-name>-r`

Example connection string:
```
postgresql://app:password@<release-name>-rw:5432/app
```
