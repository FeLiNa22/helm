{{/*
Expand the name of the chart.
*/}}
{{- define "authentik.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "authentik.fullname" -}}
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
{{- define "authentik.labels" -}}
{{ include "authentik.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "authentik.selectorLabels" -}}
app.kubernetes.io/name: {{ include "authentik.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Selector labels for server
*/}}
{{- define "authentik.selectorLabels.server" -}}
app.kubernetes.io/name: {{ include "authentik.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: server
{{- end }}

{{/*
Selector labels for worker
*/}}
{{- define "authentik.selectorLabels.worker" -}}
app.kubernetes.io/name: {{ include "authentik.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: worker
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "authentik.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "authentik.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL host
*/}}
{{- define "authentik.postgresql.host" -}}
{{- if eq .Values.postgres.mode "standalone" }}
{{- printf "%s-postgresql" (include "authentik.fullname" .) }}
{{- else if eq .Values.postgres.mode "cluster" }}
{{- printf "%s-%s-rw" .Release.Name .Values.postgres.cluster.name }}
{{- else }}
{{- .Values.postgres.external.host }}
{{- end }}
{{- end }}

{{/*
PostgreSQL port
*/}}
{{- define "authentik.postgresql.port" -}}
{{- if eq .Values.postgres.mode "external" }}
{{- .Values.postgres.external.port | default "5432" }}
{{- else }}
{{- "5432" }}
{{- end }}
{{- end }}

{{/*
PostgreSQL database name
*/}}
{{- define "authentik.postgresql.database" -}}
{{- .Values.postgres.database | default "authentik" }}
{{- end }}

{{/*
PostgreSQL username
*/}}
{{- define "authentik.postgresql.username" -}}
{{- .Values.postgres.username | default "authentik" }}
{{- end }}

{{/*
PostgreSQL secret name
*/}}
{{- define "authentik.postgresql.secretName" -}}
{{- if .Values.postgres.secret.name }}
{{- .Values.postgres.secret.name }}
{{- else }}
{{- printf "%s-postgres-secret" .Release.Name }}
{{- end }}
{{- end }}

{{/*
DragonflyDB/Redis host
*/}}
{{- define "authentik.dragonfly.host" -}}
{{- if eq .Values.dragonfly.mode "standalone" }}
{{- printf "%s-dragonfly" (include "authentik.fullname" .) }}
{{- else if eq .Values.dragonfly.mode "cluster" }}
{{- printf "%s-dragonfly-cluster" (include "authentik.fullname" .) }}
{{- else if eq .Values.dragonfly.mode "external" }}
{{- .Values.dragonfly.external.host }}
{{- end }}
{{- end }}

{{/*
DragonflyDB/Redis port
*/}}
{{- define "authentik.dragonfly.port" -}}
{{- if eq .Values.dragonfly.mode "external" }}
{{- .Values.dragonfly.external.port | default "6379" }}
{{- else }}
{{- "6379" }}
{{- end }}
{{- end }}

{{/*
DragonflyDB/Redis secret name (for password if enabled)
*/}}
{{- define "authentik.dragonfly.secretName" -}}
{{- if eq .Values.dragonfly.mode "external" }}
{{- .Values.dragonfly.external.existingSecret }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
DragonflyDB/Redis password key
*/}}
{{- define "authentik.dragonfly.passwordKey" -}}
{{- if eq .Values.dragonfly.mode "external" }}
{{- .Values.dragonfly.external.passwordKey | default "password" }}
{{- else }}
{{- "password" }}
{{- end }}
{{- end }}

{{/*
Authentik secret key - generate random if not provided
*/}}
{{- define "authentik.secretKey" -}}
{{- if .Values.authentik.secretKey }}
{{- .Values.authentik.secretKey }}
{{- else }}
{{- randAlphaNum 50 }}
{{- end }}
{{- end }}
