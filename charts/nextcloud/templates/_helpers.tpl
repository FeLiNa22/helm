{{/*
PostgreSQL secret name
*/}}
{{- define "nextcloud.postgresql.secretName" -}}
{{- if eq .Values.database.mode "standalone" }}
{{- if .Values.database.auth.existingSecret }}
{{- .Values.database.auth.existingSecret }}
{{- else }}
{{- printf "%s-postgresql" .Release.Name }}
{{- end }}
{{- else if eq .Values.database.mode "cluster" }}
{{- if .Values.database.auth.existingSecret }}
{{- .Values.database.auth.existingSecret }}
{{- else }}
{{- printf "%s-%s-app" .Release.Name .Values.database.cluster.name }}
{{- end }}
{{- else }}
{{- if not .Values.database.auth.existingSecret }}
{{- fail "database.auth.existingSecret is required when database.mode is 'external'" }}
{{- end }}
{{- .Values.database.auth.existingSecret }}
{{- end }}
{{- end }}
