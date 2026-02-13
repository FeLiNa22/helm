{{/*
Expand the name of the chart.
*/}}
{{- define "custom.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "custom.fullname" -}}
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
{{- define "custom.labels" -}}
{{ include "custom.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "custom.selectorLabels" -}}
app.kubernetes.io/name: {{ include "custom.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "custom.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "custom.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL host
*/}}
{{- define "custom.postgresql.host" -}}
{{- if eq .Values.postgres.mode "standalone" }}
{{- printf "%s-postgresql" (include "custom.fullname" .) }}
{{- else if eq .Values.postgres.mode "cluster" }}
{{- printf "%s-custom-db-rw" .Release.Name }}
{{- else }}
{{- .Values.postgres.external.host }}
{{- end }}
{{- end }}

{{/*
PostgreSQL port
*/}}
{{- define "custom.postgresql.port" -}}
{{- if eq .Values.postgres.mode "external" }}
{{- .Values.postgres.external.port | default "5432" }}
{{- else }}
{{- "5432" }}
{{- end }}
{{- end }}

{{/*
PostgreSQL database name
*/}}
{{- define "custom.postgresql.database" -}}
{{- .Values.postgres.database | default "custom" }}
{{- end }}

{{/*
PostgreSQL username
*/}}
{{- define "custom.postgresql.username" -}}
{{- .Values.postgres.username | default "custom" }}
{{- end }}

{{/*
PostgreSQL secret name
*/}}
{{- define "custom.postgresql.secretName" -}}
{{- if .Values.postgres.secret.name }}
{{- .Values.postgres.secret.name }}
{{- else }}
{{- printf "%s-postgresql" .Release.Name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL secret key
*/}}
{{- define "custom.postgresql.secretKey" -}}
{{- .Values.postgres.secret.passwordKey | default "password" }}
{{- end }}
