{{/*
Expand the name of the chart.
*/}}
{{- define "vaultwarden.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "vaultwarden.fullname" -}}
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
PostgreSQL host
*/}}
{{- define "vaultwarden.postgresql.host" -}}
{{- if eq .Values.postgres.mode "cluster" }}
{{- printf "%s-vaultwarden-db-rw" .Release.Name }}
{{- else if eq .Values.postgres.mode "external" }}
{{- .Values.postgres.external.host }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
PostgreSQL port
*/}}
{{- define "vaultwarden.postgresql.port" -}}
{{- if eq .Values.postgres.mode "external" }}
{{- .Values.postgres.external.port | default "5432" }}
{{- else if eq .Values.postgres.mode "cluster" }}
{{- "5432" }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
PostgreSQL database name
*/}}
{{- define "vaultwarden.postgresql.database" -}}
{{- .Values.postgres.database | default "vaultwarden" }}
{{- end }}

{{/*
PostgreSQL username
*/}}
{{- define "vaultwarden.postgresql.username" -}}
{{- .Values.postgres.username | default "vaultwarden" }}
{{- end }}

{{/*
PostgreSQL secret name
*/}}
{{- define "vaultwarden.postgresql.secretName" -}}
{{- if .Values.postgres.password.secretName }}
{{- .Values.postgres.password.secretName }}
{{- else }}
{{- printf "%s-postgres-secret" .Release.Name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL DATABASE_URL
Constructs the full connection string for Vaultwarden
Format: postgresql://username:password@host:port/database
Note: The password uses shell variable expansion $(DB_PASSWORD) which is populated from a Kubernetes secret.
This is a standard pattern and is secure because the password is injected at runtime from the secret.
*/}}
{{- define "vaultwarden.postgresql.databaseUrl" -}}
{{- if or (eq .Values.postgres.mode "cluster") (eq .Values.postgres.mode "external") }}
{{- $host := include "vaultwarden.postgresql.host" . }}
{{- $port := include "vaultwarden.postgresql.port" . }}
{{- $database := include "vaultwarden.postgresql.database" . }}
{{- $username := include "vaultwarden.postgresql.username" . }}
{{- printf "postgresql://%s:$(DB_PASSWORD)@%s:%s/%s" $username $host $port $database }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}
