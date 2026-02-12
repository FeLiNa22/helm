{{/*
Expand the name of the chart.
*/}}
{{- define "penpot.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "penpot.fullname" -}}
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
{{- define "penpot.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "penpot.labels" -}}
helm.sh/chart: {{ include "penpot.chart" . }}
{{ include "penpot.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "penpot.selectorLabels" -}}
app.kubernetes.io/name: {{ include "penpot.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
PostgreSQL host
*/}}
{{- define "penpot.postgresql.host" -}}
{{- if eq .Values.database.mode "standalone" }}
{{- printf "%s-postgresql" (include "penpot.fullname" .) }}
{{- else if eq .Values.database.mode "cluster" }}
{{- printf "%s-%s-rw" .Release.Name .Values.database.cluster.name }}
{{- else }}
{{- .Values.database.external.host }}
{{- end }}
{{- end }}

{{/*
PostgreSQL port
*/}}
{{- define "penpot.postgresql.port" -}}
{{- if eq .Values.database.mode "external" }}
{{- .Values.database.external.port | default "5432" }}
{{- else }}
{{- "5432" }}
{{- end }}
{{- end }}

{{/*
PostgreSQL database name
*/}}
{{- define "penpot.postgresql.database" -}}
{{- .Values.database.auth.username }}
{{- end }}

{{/*
PostgreSQL username
*/}}
{{- define "penpot.postgresql.username" -}}
{{- .Values.database.auth.username }}
{{- end }}

{{/*
PostgreSQL secret name
*/}}
{{- define "penpot.postgresql.secretName" -}}
{{- if .Values.database.secret.name }}
{{- .Values.database.secret.name }}
{{- else }}
{{- printf "%s-postgresql" .Release.Name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL secret key
*/}}
{{- define "penpot.postgresql.secretKey" -}}
{{- .Values.database.secret.passwordKey | default "password" }}
{{- end }}

{{/*
DragonflyDB/Redis host
*/}}
{{- define "penpot.dragonfly.host" -}}
{{- if eq .Values.dragonfly.mode "standalone" }}
{{- printf "%s-dragonfly" (include "penpot.fullname" .) }}
{{- else if eq .Values.dragonfly.mode "cluster" }}
{{- printf "%s-dragonfly-cluster" (include "penpot.fullname" .) }}
{{- else if eq .Values.dragonfly.mode "external" }}
{{- .Values.dragonfly.external.host }}
{{- end }}
{{- end }}

{{/*
DragonflyDB/Redis port
*/}}
{{- define "penpot.dragonfly.port" -}}
{{- if eq .Values.dragonfly.mode "external" }}
{{- .Values.dragonfly.external.port | default "6379" }}
{{- else }}
{{- "6379" }}
{{- end }}
{{- end }}

{{/*
DragonflyDB/Redis secret name (for password if enabled)
*/}}
{{- define "penpot.dragonfly.secretName" -}}
{{- if eq .Values.dragonfly.mode "external" }}
{{- .Values.dragonfly.external.existingSecret }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
DragonflyDB/Redis password key
*/}}
{{- define "penpot.dragonfly.passwordKey" -}}
{{- if eq .Values.dragonfly.mode "external" }}
{{- .Values.dragonfly.external.passwordKey | default "password" }}
{{- else }}
{{- "password" }}
{{- end }}
{{- end }}
