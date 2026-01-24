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
Create chart name and version as used by the chart label.
*/}}
{{- define "immich.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "immich.labels" -}}
helm.sh/chart: {{ include "immich.chart" . }}
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
{{- if eq .Values.postgresql.mode "standalone" }}
{{- printf "%s-postgresql-standalone" .Release.Name }}
{{- else if eq .Values.postgresql.mode "cluster" }}
{{- printf "%s-%s-rw" .Release.Name .Values.postgresql.cluster.name }}
{{- else }}
{{- .Values.postgresql.external.host }}
{{- end }}
{{- end }}

{{/*
PostgreSQL port
*/}}
{{- define "immich.postgresql.port" -}}
{{- if eq .Values.postgresql.mode "external" }}
{{- .Values.postgresql.external.port | default "5432" }}
{{- else }}
{{- "5432" }}
{{- end }}
{{- end }}

{{/*
PostgreSQL database name
*/}}
{{- define "immich.postgresql.database" -}}
{{- if eq .Values.postgresql.mode "standalone" }}
{{- .Values.postgresql.standalone.auth.database }}
{{- else if eq .Values.postgresql.mode "cluster" }}
{{- .Values.postgresql.cluster.database }}
{{- else }}
{{- .Values.postgresql.external.database }}
{{- end }}
{{- end }}

{{/*
PostgreSQL username
*/}}
{{- define "immich.postgresql.username" -}}
{{- if eq .Values.postgresql.mode "standalone" }}
{{- .Values.postgresql.standalone.auth.username }}
{{- else if eq .Values.postgresql.mode "cluster" }}
{{- .Values.postgresql.cluster.secret.username }}
{{- else }}
{{- .Values.postgresql.external.username }}
{{- end }}
{{- end }}

{{/*
PostgreSQL secret name
*/}}
{{- define "immich.postgresql.secretName" -}}
{{- if eq .Values.postgresql.mode "standalone" }}
{{- if .Values.postgresql.standalone.auth.existingSecret }}
{{- .Values.postgresql.standalone.auth.existingSecret }}
{{- else }}
{{- printf "%s-postgresql-standalone" .Release.Name }}
{{- end }}
{{- else if eq .Values.postgresql.mode "cluster" }}
{{- .Values.postgresql.cluster.secret.name | default (printf "%s-immich-db-app" .Release.Name) }}
{{- else }}
{{- .Values.postgresql.external.existingSecret }}
{{- end }}
{{- end }}

{{/*
PostgreSQL secret key
*/}}
{{- define "immich.postgresql.secretKey" -}}
{{- if eq .Values.postgresql.mode "standalone" }}
{{- "password" }}
{{- else if eq .Values.postgresql.mode "cluster" }}
{{- "password" }}
{{- else }}
{{- .Values.postgresql.external.secretKey | default "password" }}
{{- end }}
{{- end }}

{{/*
DragonflyDB/Redis host
*/}}
{{- define "immich.dragonfly.host" -}}
{{- if eq .Values.dragonfly.mode "standalone" }}
{{- printf "%s-dragonfly" (include "immich.fullname" .) }}
{{- else if eq .Values.dragonfly.mode "cluster" }}
{{- printf "%s-dragonfly-cluster" (include "immich.fullname" .) }}
{{- else }}
{{- .Values.dragonfly.external.host }}
{{- end }}
{{- end }}

{{/*
DragonflyDB/Redis port
*/}}
{{- define "immich.dragonfly.port" -}}
{{- if eq .Values.dragonfly.mode "disabled" }}
{{- .Values.dragonfly.external.port | default "6379" }}
{{- else }}
{{- "6379" }}
{{- end }}
{{- end }}

{{/*
DragonflyDB/Redis secret name (for password if enabled)
*/}}
{{- define "immich.dragonfly.secretName" -}}
{{- if eq .Values.dragonfly.mode "disabled" }}
{{- .Values.dragonfly.external.existingSecret }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
DragonflyDB/Redis password key
*/}}
{{- define "immich.dragonfly.passwordKey" -}}
{{- if eq .Values.dragonfly.mode "disabled" }}
{{- .Values.dragonfly.external.passwordKey | default "password" }}
{{- else }}
{{- "password" }}
{{- end }}
{{- end }}
