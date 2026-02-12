{{/*
PostgreSQL secret name
*/}}
{{- define "nextcloud.postgresql.secretName" -}}
{{- if .Values.database.secret.name }}
{{- .Values.database.secret.name }}
{{- else }}
{{- printf "%s-postgresql" .Release.Name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL secret key
*/}}
{{- define "nextcloud.postgresql.secretKey" -}}
{{- .Values.database.secret.passwordKey | default "password" }}
{{- end }}
