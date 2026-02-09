# GitHub Copilot Instructions for Helm Charts

## Chart Version Management

**CRITICAL**: When making ANY changes to Helm charts in the `charts/` directory, you MUST bump the chart version in the `Chart.yaml` file.

### Version Bumping Rules

1. **Always bump the version** when:
   - Modifying any template files (`templates/**/*.yaml`)
   - Changing `values.yaml`
   - Updating `Chart.yaml` metadata (except the version field itself)
   - Modifying `README.md` that affects configuration
   - Adding or removing chart dependencies

2. **Version increment guidelines**:
   - **Patch version** (0.0.X): Bug fixes, minor tweaks, documentation updates that don't change functionality
   - **Minor version** (0.X.0): New features, new configuration options, backward-compatible changes
   - **Major version** (X.0.0): Breaking changes, major refactoring, incompatible API changes

3. **How to bump**:
   - Locate the `version:` field in `charts/<chart-name>/Chart.yaml`
   - Increment according to semantic versioning (semver)
   - Example: `version: 1.0.6` → `version: 1.0.7` (patch) or `version: 1.1.0` (minor)

### Workflow Checklist

When editing any chart:
- [ ] Make the requested changes to templates, values, or other chart files
- [ ] Update the `version:` field in `Chart.yaml`
- [ ] Update the `README.md` if parameter changes were made
- [ ] Verify all template references are correct

### Example

```yaml
# charts/myapp/Chart.yaml
apiVersion: v2
name: myapp
version: 1.2.3  # ← ALWAYS UPDATE THIS
```

## Environment Variables Convention

**IMPORTANT**: All environment variables in charts MUST use **map format**, not array format.

### Map Format (Required)

In `values.yaml`:
```yaml
env:
  TZ: "Europe/London"
  LOG_LEVEL: "info"
  MY_VAR: "value"
```

In templates (`deployment.yaml`):
```gotemplate
{{- if .Values.env }}
env:
  {{- range $k,$v := .Values.env }}
  - name: {{ $k }}
    value: {{ $v | quote }}
  {{- end }}
{{- end }}
```

### Array Format (NOT Allowed)

Do NOT use this format:
```yaml
# values.yaml - WRONG
env:
  - name: TZ
    value: "Europe/London"
```

```gotemplate
# deployment.yaml - WRONG
env:
  {{- toYaml .Values.env | nindent 12 }}
```

### Why Map Format?

1. **Simpler syntax**: Easier to read and write for users
2. **Consistent merging**: Helm value merging works predictably with maps
3. **No patching errors**: Avoids Kubernetes strategic merge patch errors like "cannot restore slice from map"
4. **Uniform across charts**: All services follow the same convention

## Chart Structure Standards

**CRITICAL**: All charts MUST follow a standardized structure to ensure consistency, maintainability, and feature parity across the repository.

### Required Sections in values.yaml

Every chart must include the following sections in this order:

#### 1. Image Configuration
```yaml
image:
  repository: <registry/image>
  pullPolicy: IfNotPresent
  tag: "version"
  autoupdate:
    enabled: false
    strategy: ""
    allowTags: ""
    ignoreTags: []
    pullSecret: ""
    platforms: []
```

**Requirements**:
- Image autoupdate section MUST be present
- Supports ArgoCD Image Updater integration
- Strategy options: semver, latest, newest-build, name, alphabetical, digest
- allowTags supports regexp patterns (e.g., `"regexp:^[0-9]+\\.[0-9]+\\.[0-9]+$"`)

#### 2. Environment Variables
```yaml
env:
  TZ: "Europe/London"
  # Additional env vars in map format
```

**Requirements**:
- MUST use map format (key: value)
- NEVER use array format with name/value pairs
- See "Environment Variables Convention" section for details

#### 3. Persistence Configuration
```yaml
persistence:
  enabled: true
  storageClass: ""
  existingClaim: ""
  accessMode: ReadWriteOnce
  size: 512Mi
  additionalVolumes: []
  additionalMounts: []
```

**Requirements**:
- Main data persistence section MUST be present
- additionalVolumes and additionalMounts MUST be included for custom volume/mount support
- Support for existingClaim to use pre-existing PVCs

#### 4. Cache Mount Support
For services that benefit from caching (ML models, media transcoding, etc.):

```yaml
# Example: ML cache for Immich
machineLearning:
  persistence:
    enabled: true
    storageClass: ""
    size: 512Mi
    accessMode: ReadWriteOnce

# Example: Generic cache volume
cache:
  enabled: true
  storageClass: ""
  size: 1Gi
  accessMode: ReadWriteOnce
```

**Requirements**:
- Cache volumes should be separate from main data persistence
- Include when service has caching needs (temporary files, models, transcoding)
- Cache size should be appropriate for the service's use case

#### 5. Database Configuration (when applicable)
All charts requiring a database MUST support three modes: standalone, cluster, and external.

```yaml
database:
  # Mode options: 'standalone', 'cluster', or 'external'
  mode: standalone

  # Common database configuration
  persistence:
    enabled: true
    size: 512Mi
    storageClass: ""
    existingClaim: ""

  # SQL commands to initialize extensions/schema
  initSQL: []

  auth:
    username: appname
    password: ""  # Leave empty to auto-generate

  # Secret configuration for database password
  secret:
    name: ""  # Leave empty to auto-generate
    passwordKey: "password"

  # Standalone PostgreSQL deployment (using StatefulSet)
  standalone:
    image:
      repository: postgres
      tag: "16-alpine"
      autoupdate:
        enabled: false
        updateStrategy: ""
    resources: {}

  # CloudNativePG Cluster deployment (using CNPG operator)
  cluster:
    name: app-db
    instances: 2
    image:
      repository: ghcr.io/cloudnative-pg/postgresql
      tag: "16"
    pitrBackup:
      enabled: false
      retentionPolicy: "30d"
      objectStorage:
        destinationPath: ""
        endpointURL: ""
        secretName: ""
        region: ""

  # External database configuration
  external:
    host: ""
    port: 5432
    database: "appname"
    username: "appname"

  # Scheduled database backups using pg_dump (works for all modes)
  backup:
    enabled: false
    cron: "0 2 * * *"  # Daily at 2am
    retention: 30
    path: /backups
    persistence:
      enabled: true
      size: 512Mi
      storageClass: ""
      accessMode: ReadWriteOnce
      existingClaim: ""
```

**Requirements**:
- All three modes (standalone, cluster, external) MUST be supported
- Standalone: Simple StatefulSet deployment for development/testing
- Cluster: CloudNativePG operator integration for production HA
- External: Connect to existing database infrastructure
- Database images with autoupdate support for standalone mode
- PITR backups for CNPG cluster mode
- Optional pg_dump backups for all modes

#### 6. Cache/Queue Database (Redis/DragonflyDB)
For services requiring Redis/cache:

```yaml
dragonfly:
  # Mode options: 'standalone', 'cluster', 'external', or 'disabled'
  mode: standalone

  # Standalone Dragonfly deployment
  standalone:
    image:
      repository: docker.dragonflydb.io/dragonflydb/dragonfly
      tag: "v1.36.0"
    resources: {}
    persistence:
      enabled: true
      size: 512Mi
      storageClass: ""

  # Dragonfly Cluster deployment
  cluster:
    replicas: 2
    image:
      repository: docker.dragonflydb.io/dragonflydb/dragonfly
      tag: "v1.36.0"
    resources: {}
    persistence:
      enabled: true
      size: 512Mi
      storageClass: ""

  # External configuration
  external:
    host: ""
    port: 6379
    existingSecret: ""
    passwordKey: "password"
```

**Requirements**:
- Support standalone, cluster, external, and disabled modes
- Use DragonflyDB as default (Redis-compatible, better performance)
- All modes MUST be fully functional

#### 7. Velero Backup Schedule
```yaml
velero:
  enabled: false
  namespace: "velero"
  schedule: "0 2 * * *"
  ttl: "168h"
  includeClusterResources: false
  snapshotVolumes: true
  defaultVolumesToFsBackup: false
  storageLocation: ""
  volumeSnapshotLocations: []
  labelSelector: {}
  annotations: {}
```

**Requirements**:
- Velero backup configuration MUST be present in all charts
- Default to disabled (users opt-in)
- Schedule CRD created in Velero namespace
- Default schedule: daily at 2am
- Default TTL: 7 days (168h)
- Support both volume snapshots and filesystem backups

#### 8. ArgoCD Image Updater
```yaml
imageUpdater:
  namespace: argocd
  argocdNamespace: argocd
  applicationName: ""
  imageAlias: ""
  forceUpdate: false
  helm: {}
  kustomize: {}
  writeBackConfig: {}
```

**Requirements**:
- ArgoCD Image Updater section MUST be present
- Enables GitOps-based image update workflows
- Supports both Helm and Kustomize deployments

### Template Requirements

#### Database Templates
When implementing database support:
- Create separate templates for each mode (standalone, cluster, external)
- Use conditionals to deploy only the selected mode
- Ensure connection strings are properly constructed for each mode
- Handle secrets properly (auto-generate or use existing)
- Include init containers for schema/extension initialization

#### Volume and Mount Templates
- Use `additionalVolumes` and `additionalMounts` for flexibility
- Support emptyDir for ephemeral caching needs
- Support PVC for persistent caching
- Document mount paths in README.md

#### Velero Templates
- Create Schedule CRD in Velero namespace
- Include namespace selector for the application namespace
- Support custom label selectors
- Allow storage location configuration

## Additional Guidelines

- **Test changes**: Ensure templates render correctly with `helm template`
- **Document parameters**: Keep README.md in sync with values.yaml
- **Backward compatibility**: Avoid breaking changes in minor/patch versions
- **Changelog**: Consider mentioning significant changes in Chart.yaml annotations
- **Standard sections**: All charts must include the required sections listed above
- **Multi-mode support**: Database and cache components must support all deployment modes

---

**Remember**: No chart update is complete without a version bump!
