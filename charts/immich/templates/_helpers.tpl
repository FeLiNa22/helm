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
{{- if eq .Values.database.mode "standalone" }}
{{- printf "%s-postgresql" (include "immich.fullname" .) }}
{{- else if eq .Values.database.mode "cluster" }}
{{- printf "%s-%s-rw" .Release.Name .Values.database.cluster.name }}
{{- else }}
{{- .Values.database.external.host }}
{{- end }}
{{- end }}

{{/*
PostgreSQL port
*/}}
{{- define "immich.postgresql.port" -}}
{{- if eq .Values.database.mode "external" }}
{{- .Values.database.external.port | default "5432" }}
{{- else }}
{{- "5432" }}
{{- end }}
{{- end }}

{{/*
PostgreSQL database name
*/}}
{{- define "immich.postgresql.database" -}}
{{- if eq .Values.database.mode "external" }}
{{- .Values.database.external.database | default "immich" }}
{{- else }}
{{- .Values.database.auth.username }}
{{- end }}
{{- end }}

{{/*
PostgreSQL username
*/}}
{{- define "immich.postgresql.username" -}}
{{- if eq .Values.database.mode "external" }}
{{- .Values.database.external.username | default "immich" }}
{{- else }}
{{- .Values.database.auth.username }}
{{- end }}
{{- end }}

{{/*
PostgreSQL secret name
*/}}
{{- define "immich.postgresql.secretName" -}}
{{- if .Values.database.secret.name }}
{{- .Values.database.secret.name }}
{{- else }}
{{- printf "%s-postgresql" .Release.Name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL secret key
*/}}
{{- define "immich.postgresql.secretKey" -}}
{{- .Values.database.secret.passwordKey | default "password" }}
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
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
DragonflyDB/Redis password key
*/}}
{{- define "immich.dragonfly.passwordKey" -}}
{{- if eq .Values.dragonfly.mode "external" }}
{{- .Values.dragonfly.external.passwordKey | default "password" }}
{{- else }}
{{- "password" }}
{{- end }}
{{- end }}
