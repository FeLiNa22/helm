{{/*
Seerr Database Host
*/}}
{{- define "seerr.database.host" -}}
{{- if eq .Values.seerr.database.mode "cluster" }}
{{- printf "%s-seerr-db-rw" .Release.Name }}
{{- else if eq .Values.seerr.database.mode "external" }}
{{- .Values.seerr.database.external.host }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
Seerr Database Port
*/}}
{{- define "seerr.database.port" -}}
{{- if or (eq .Values.seerr.database.mode "cluster") (eq .Values.seerr.database.mode "external") }}
{{- .Values.seerr.database.port | default "5432" }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
Seerr Database Username
*/}}
{{- define "seerr.database.username" -}}
{{- if eq .Values.seerr.database.mode "cluster" }}
{{- "seerr" }}
{{- else if eq .Values.seerr.database.mode "external" }}
{{- .Values.seerr.database.external.username }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
Seerr Database Name
*/}}
{{- define "seerr.database.name" -}}
{{- if or (eq .Values.seerr.database.mode "cluster") (eq .Values.seerr.database.mode "external") }}
{{- .Values.seerr.database.databaseName | default "jellyseerr" }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
Seerr Database Secret Name
*/}}
{{- define "seerr.database.secretName" -}}
{{- if eq .Values.seerr.database.mode "cluster" }}
{{- if .Values.seerr.database.auth.existingSecret }}
{{- .Values.seerr.database.auth.existingSecret }}
{{- else }}
{{- printf "%s-seerr-db-app" .Release.Name }}
{{- end }}
{{- else }}
{{- if not .Values.seerr.database.external.existingSecret }}
{{- fail "seerr.database.external.existingSecret is required when seerr.database.mode is 'external'" }}
{{- end }}
{{- .Values.seerr.database.external.existingSecret }}
{{- end }}
{{- end }}
