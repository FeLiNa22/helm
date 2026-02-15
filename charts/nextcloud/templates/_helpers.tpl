{{/*
PostgreSQL secret name
*/}}
{{- define "nextcloud.postgresql.secretName" -}}
{{- if .Values.postgres.password.secretName }}
{{- .Values.postgres.password.secretName }}
{{- else }}
{{- printf "%s-postgres-secret" .Release.Name }}
{{- end }}
{{- end }}



{{/*
PostgreSQL host
*/}}
{{- define "nextcloud.postgresql.host" -}}
{{- printf "%s-nextcloud-db-rw" .Release.Name }}
{{- end }}

{{/*
PostgreSQL database name
*/}}
{{- define "nextcloud.postgresql.database" -}}
{{- .Values.postgres.database | default "nextcloud" }}
{{- end }}

{{/*
PostgreSQL username
*/}}
{{- define "nextcloud.postgresql.username" -}}
{{- .Values.postgres.username | default "nextcloud" }}
{{- end }}
