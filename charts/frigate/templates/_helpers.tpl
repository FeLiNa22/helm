{{/*
PostgreSQL secret name
*/}}
{{- define "frigate.postgresql.secretName" -}}
{{- if .Values.postgres.secret.name }}
{{- .Values.postgres.secret.name }}
{{- else }}
{{- printf "%s-postgresql" .Release.Name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL secret key
*/}}
{{- define "frigate.postgresql.secretKey" -}}
{{- .Values.postgres.secret.passwordKey | default "password" }}
{{- end }}

{{/*
PostgreSQL host
*/}}
{{- define "frigate.postgresql.host" -}}
{{- printf "%s-frigate-db-rw" .Release.Name }}
{{- end }}

{{/*
PostgreSQL database name
*/}}
{{- define "frigate.postgresql.database" -}}
{{- .Values.postgres.database | default "frigate" }}
{{- end }}

{{/*
PostgreSQL username
*/}}
{{- define "frigate.postgresql.username" -}}
{{- .Values.postgres.username | default "frigate" }}
{{- end }}
