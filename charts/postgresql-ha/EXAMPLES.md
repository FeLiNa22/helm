# PostgreSQL Cluster - Example Configurations

## Basic 3-node cluster

```yaml
enabled: true

cluster:
  instances: 3

storage:
  size: 20Gi
  storageClass: local-path

superuserSecret:
  create: true
  password: "supersecurepassword"

appSecret:
  create: true
  username: myapp
  password: "myapppassword"

bootstrap:
  initdb:
    database: myappdb
    owner: myapp
```

## High-Performance Configuration

```yaml
enabled: true

cluster:
  instances: 3

storage:
  size: 100Gi
  storageClass: fast-ssd

postgresql:
  parameters:
    max_connections: "500"
    shared_buffers: "2GB"
    effective_cache_size: "6GB"
    maintenance_work_mem: "512MB"
    checkpoint_completion_target: "0.9"
    wal_buffers: "16MB"
    default_statistics_target: "500"
    random_page_cost: "1.1"
    effective_io_concurrency: "200"
    work_mem: "4MB"
    min_wal_size: "2GB"
    max_wal_size: "8GB"
    max_worker_processes: "4"
    max_parallel_workers_per_gather: "2"
    max_parallel_workers: "4"
    max_parallel_maintenance_workers: "2"

resources:
  requests:
    cpu: 2000m
    memory: 8Gi
  limits:
    cpu: 4000m
    memory: 16Gi
```

## With Backups to S3

```yaml
enabled: true

cluster:
  instances: 3

storage:
  size: 50Gi

backup:
  enabled: true
  schedule: "0 2 * * *"  # Daily at 2 AM
  retentionPolicy: "30d"
  s3:
    enabled: true
    bucket: my-postgres-backups
    region: us-east-1
    path: /prod-cluster
    endpointURL: https://s3.amazonaws.com
    secret:
      name: s3-credentials  # Create this secret with ACCESS_KEY_ID and ACCESS_SECRET_KEY

superuserSecret:
  create: true

appSecret:
  create: true
```

## With PgBouncer Connection Pooler

```yaml
enabled: true

cluster:
  instances: 3

storage:
  size: 20Gi

pooler:
  enabled: true
  instances: 3
  type: rw
  poolMode: transaction
  parameters:
    max_client_conn: "1000"
    default_pool_size: "25"
    reserve_pool_size: "5"
    pool_mode: transaction
    max_db_connections: "0"
    max_user_connections: "0"

superuserSecret:
  create: true

appSecret:
  create: true
```

## For Development (Single Instance)

```yaml
enabled: true

cluster:
  instances: 1

storage:
  size: 5Gi

superuserSecret:
  create: true
  password: "devpassword"

appSecret:
  create: true
  username: dev
  password: "devpassword"

bootstrap:
  initdb:
    database: devdb
    owner: dev

resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 1Gi
```

## Connection Examples

### Connecting from Applications

For services like Nextcloud, Immich, or Home Assistant:

```yaml
# In your application's values.yaml
database:
  host: my-postgres-rw  # Read-Write service
  port: 5432
  database: myappdb
  username: myapp
  password: myapppassword
```

### Using Read Replicas

```yaml
# For read-heavy operations
readDatabase:
  host: my-postgres-ro  # Read-Only service (load balanced across replicas)
  port: 5432
  database: myappdb
  username: myapp
  password: myapppassword

# For read operations
readService:
  host: my-postgres-r  # Read service (includes primary)
  port: 5432
```

### With PgBouncer

```yaml
database:
  host: my-postgres-pooler-rw  # Through connection pooler
  port: 5432
  database: myappdb
  username: myapp
  password: myapppassword
```

## Creating Secrets for S3 Backups

```bash
kubectl create secret generic s3-credentials \
  --from-literal=ACCESS_KEY_ID=your-access-key \
  --from-literal=ACCESS_SECRET_KEY=your-secret-key
```

## Monitoring with Prometheus

```yaml
monitoring:
  enabled: true
  podMonitorEnabled: true  # Requires Prometheus Operator
```

## Scaling the Cluster

To scale up or down, simply change the `cluster.instances` value:

```bash
# Scale to 5 instances
helm upgrade my-postgres ./postgresql-cluster --set cluster.instances=5

# Scale down to 2 instances
helm upgrade my-postgres ./postgresql-cluster --set cluster.instances=2
```

The operator will handle the scaling automatically with minimal downtime.
