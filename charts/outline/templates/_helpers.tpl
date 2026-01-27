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
{{- if eq .Values.database.mode "standalone" }}
{{- printf "%s-postgresql" (include "outline.fullname" .) }}
{{- else if eq .Values.database.mode "cluster" }}
{{- printf "%s-%s-rw" .Release.Name .Values.database.cluster.name }}
{{- else }}
{{- .Values.database.external.host }}
{{- end }}
{{- end }}

{{/*
PostgreSQL port
*/}}
{{- define "outline.postgresql.port" -}}
{{- if eq .Values.database.mode "external" }}
{{- .Values.database.external.port | default "5432" }}
{{- else }}
{{- "5432" }}
{{- end }}
{{- end }}

{{/*
PostgreSQL database name
*/}}
{{- define "outline.postgresql.database" -}}
{{- if eq .Values.database.mode "standalone" }}
{{- .Values.database.standalone.auth.database }}
{{- else if eq .Values.database.mode "cluster" }}
{{- .Values.database.cluster.database }}
{{- else }}
{{- .Values.database.external.database }}
{{- end }}
{{- end }}

{{/*
PostgreSQL username
*/}}
{{- define "outline.postgresql.username" -}}
{{- if eq .Values.database.mode "standalone" }}
{{- .Values.database.standalone.auth.username }}
{{- else if eq .Values.database.mode "cluster" }}
{{- .Values.database.cluster.secret.username }}
{{- else }}
{{- .Values.database.external.username }}
{{- end }}
{{- end }}

{{/*
PostgreSQL secret name
*/}}
{{- define "outline.postgresql.secretName" -}}
{{- if eq .Values.database.mode "standalone" }}
{{- if .Values.database.standalone.auth.existingSecret }}
{{- .Values.database.standalone.auth.existingSecret }}
{{- else }}
{{- printf "%s-postgresql" .Release.Name }}
{{- end }}
{{- else if eq .Values.database.mode "cluster" }}
{{- .Values.database.cluster.secret.name | default (printf "%s-outline-db-app" .Release.Name) }}
{{- else }}
{{- .Values.database.external.existingSecret }}
{{- end }}
{{- end }}

{{/*
PostgreSQL secret key
*/}}
{{- define "outline.postgresql.secretKey" -}}
{{- if eq .Values.database.mode "standalone" }}
{{- "password" }}
{{- else if eq .Values.database.mode "cluster" }}
{{- "password" }}
{{- else }}
{{- .Values.database.external.secretKey | default "password" }}
{{- end }}
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
