{{/*
PostgreSQL secret name
*/}}
{{- define "nextcloud.postgresql.secretName" -}}
{{- if .Values.database.auth.existingSecret }}
{{- .Values.database.auth.existingSecret }}
{{- else }}
{{- printf "%s-postgresql" .Release.Name }}
{{- end }}
{{- end }}
