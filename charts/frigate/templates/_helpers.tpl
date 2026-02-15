{{/*
PostgreSQL secret name
*/}}
{{- define "frigate.postgresql.secretName" -}}
{{- if .Values.postgres.password.secretName }}
{{- .Values.postgres.password.secretName }}
{{- else }}
{{- printf "%s-postgres-secret" .Release.Name }}
{{- end }}
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
