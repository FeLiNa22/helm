{{/*
Expand the name of the chart.
*/}}
{{- define "outline.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "outline.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "outline.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "outline.labels" -}}
helm.sh/chart: {{ include "outline.chart" . }}
{{ include "outline.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "outline.selectorLabels" -}}
app.kubernetes.io/name: {{ include "outline.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
PostgreSQL host
*/}}
{{- define "outline.postgresql.host" -}}
{{- printf "%s-outline-db-rw" .Release.Name }}
{{- end }}

{{/*
PostgreSQL port
*/}}
{{- define "outline.postgresql.port" -}}
{{- "5432" }}
{{- end }}

{{/*
PostgreSQL database name
*/}}
{{- define "outline.postgresql.database" -}}
{{- .Values.postgres.database | default "outline" }}
{{- end }}

{{/*
PostgreSQL username
*/}}
{{- define "outline.postgresql.username" -}}
{{- .Values.postgres.username | default "outline" }}
{{- end }}

{{/*
PostgreSQL secret name
*/}}
{{- define "outline.postgresql.secretName" -}}
{{- if .Values.postgres.password.secretName }}
{{- .Values.postgres.password.secretName }}
{{- else }}
{{- printf "%s-postgres-secret" .Release.Name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL secret key
*/}}
{{- define "outline.postgresql.secretKey" -}}
{{- .Values.postgres.password.secretKey | default "password" }}
{{- end }}

{{/*
DragonflyDB/Redis host
*/}}
{{- define "outline.dragonfly.host" -}}
{{- if eq .Values.dragonfly.mode "standalone" }}
{{- printf "%s-dragonfly" (include "outline.fullname" .) }}
{{- else if eq .Values.dragonfly.mode "cluster" }}
{{- printf "%s-dragonfly-cluster" (include "outline.fullname" .) }}
{{- else if eq .Values.dragonfly.mode "external" }}
{{- .Values.dragonfly.external.host }}
{{- end }}
{{- end }}

{{/*
DragonflyDB/Redis port
*/}}
{{- define "outline.dragonfly.port" -}}
{{- if eq .Values.dragonfly.mode "external" }}
{{- .Values.dragonfly.external.port | default "6379" }}
{{- else }}
{{- "6379" }}
{{- end }}
{{- end }}

{{/*
DragonflyDB/Redis secret name (for password if enabled)
*/}}
{{- define "outline.dragonfly.secretName" -}}
{{- if eq .Values.dragonfly.mode "external" }}
{{- .Values.dragonfly.external.existingSecret }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
DragonflyDB/Redis password key
*/}}
{{- define "outline.dragonfly.passwordKey" -}}
{{- if eq .Values.dragonfly.mode "external" }}
{{- .Values.dragonfly.external.passwordKey | default "password" }}
{{- else }}
{{- "password" }}
{{- end }}
{{- end }}
