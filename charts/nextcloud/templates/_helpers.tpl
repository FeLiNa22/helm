{{/*
PostgreSQL secret name
*/}}
{{- define "nextcloud.postgresql.secretName" -}}
{{- if .Values.postgres.secret.name }}
{{- .Values.postgres.secret.name }}
{{- else }}
{{- printf "%s-postgresql" .Release.Name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL secret key
*/}}
{{- define "nextcloud.postgresql.secretKey" -}}
{{- .Values.postgres.secret.passwordKey | default "password" }}
{{- end }}
