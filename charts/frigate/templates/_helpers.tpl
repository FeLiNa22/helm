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
