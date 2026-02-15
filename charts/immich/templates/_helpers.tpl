{{/*
Expand the name of the chart.
*/}}
{{- define "immich.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "immich.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "immich.labels" -}}
{{ include "immich.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "immich.selectorLabels" -}}
app.kubernetes.io/name: {{ include "immich.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "immich.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "immich.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL host
*/}}
{{- define "immich.postgresql.host" -}}
{{- if eq .Values.postgres.mode "standalone" }}
{{- printf "%s-postgresql" (include "immich.fullname" .) }}
{{- else if eq .Values.postgres.mode "cluster" }}
{{- printf "%s-immich-db-rw" .Release.Name }}
{{- else }}
{{- .Values.postgres.external.host }}
{{- end }}
{{- end }}

{{/*
PostgreSQL port
*/}}
{{- define "immich.postgresql.port" -}}
{{- if eq .Values.postgres.mode "external" }}
{{- .Values.postgres.external.port | default "5432" }}
{{- else }}
{{- "5432" }}
{{- end }}
{{- end }}

{{/*
PostgreSQL database name
*/}}
{{- define "immich.postgresql.database" -}}
{{- .Values.postgres.database | default "immich" }}
{{- end }}

{{/*
PostgreSQL username
*/}}
{{- define "immich.postgresql.username" -}}
{{- .Values.postgres.username | default "immich" }}
{{- end }}

{{/*
PostgreSQL secret name
*/}}
{{- define "immich.postgresql.secretName" -}}
{{- if .Values.postgres.password.secretName }}
{{- .Values.postgres.password.secretName }}
{{- else }}
{{- printf "%s-postgres-secret" .Release.Name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL secret key
*/}}
{{- define "immich.postgresql.secretKey" -}}
{{- .Values.postgres.password.secretKey | default "password" }}
{{- end }}

{{/*
DragonflyDB/Redis host
*/}}
{{- define "immich.dragonfly.host" -}}
{{- if eq .Values.dragonfly.mode "standalone" }}
{{- printf "%s-dragonfly" (include "immich.fullname" .) }}
{{- else if eq .Values.dragonfly.mode "cluster" }}
{{- printf "%s-dragonfly-cluster" (include "immich.fullname" .) }}
{{- else if eq .Values.dragonfly.mode "external" }}
{{- .Values.dragonfly.external.host }}
{{- end }}
{{- end }}

{{/*
DragonflyDB/Redis port
*/}}
{{- define "immich.dragonfly.port" -}}
{{- if eq .Values.dragonfly.mode "external" }}
{{- .Values.dragonfly.external.port | default "6379" }}
{{- else }}
{{- "6379" }}
{{- end }}
{{- end }}

{{/*
DragonflyDB/Redis secret name (for password if enabled)
*/}}
{{- define "immich.dragonfly.secretName" -}}
{{- if eq .Values.dragonfly.mode "external" }}
{{- .Values.dragonfly.external.existingSecret }}
{{- else if .Values.dragonfly.auth.password.secretName }}
{{- .Values.dragonfly.auth.password.secretName }}
{{- else }}
{{- printf "%s-dragonfly-secret" .Release.Name }}
{{- end }}
{{- end }}

{{/*
DragonflyDB/Redis password key
*/}}
{{- define "immich.dragonfly.passwordKey" -}}
{{- if eq .Values.dragonfly.mode "external" }}
{{- .Values.dragonfly.external.passwordKey | default "password" }}
{{- else }}
{{- .Values.dragonfly.auth.password.secretKey | default "password" }}
{{- end }}
{{- end }}

{{/*
DragonflyDB/Redis username
*/}}
{{- define "immich.dragonfly.username" -}}
{{- .Values.dragonfly.auth.username | default "default" }}
{{- end }}
