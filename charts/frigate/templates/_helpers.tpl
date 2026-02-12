{{/*
PostgreSQL secret name
*/}}
{{- define "frigate.postgresql.secretName" -}}
{{- if .Values.database.secret.name }}
{{- .Values.database.secret.name }}
{{- else }}
{{- printf "%s-postgresql" .Release.Name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL secret key
*/}}
{{- define "frigate.postgresql.secretKey" -}}
{{- .Values.database.secret.passwordKey | default "password" }}
{{- end }}
