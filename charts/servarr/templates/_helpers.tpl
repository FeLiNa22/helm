{{/*
Seerr Database Host
*/}}
{{- define "seerr.database.host" -}}
{{- if or (eq .Values.seerr.database.mode "cluster") (eq .Values.seerr.database.mode "standalone") }}
{{- printf "%s-seerr-db-rw" .Release.Name }}
{{- else if eq .Values.seerr.database.mode "external" }}
{{- required "seerr.database.external.host is required when seerr.database.mode is 'external'" .Values.seerr.database.external.host }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
Seerr Database Port
*/}}
{{- define "seerr.database.port" -}}
{{- if eq .Values.seerr.database.mode "external" }}
{{- .Values.seerr.database.external.port | default "5432" }}
{{- else if or (eq .Values.seerr.database.mode "cluster") (eq .Values.seerr.database.mode "standalone") }}
{{- "5432" }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
Seerr Database Username
*/}}
{{- define "seerr.database.username" -}}
{{- if or (eq .Values.seerr.database.mode "cluster") (eq .Values.seerr.database.mode "standalone") }}
{{- "seerr" }}
{{- else if eq .Values.seerr.database.mode "external" }}
{{- required "seerr.database.external.username is required when seerr.database.mode is 'external'" .Values.seerr.database.external.username }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
Seerr Database Name
*/}}
{{- define "seerr.database.name" -}}
{{- if or (eq .Values.seerr.database.mode "cluster") (eq .Values.seerr.database.mode "external") (eq .Values.seerr.database.mode "standalone") }}
{{- .Values.seerr.database.databaseName | default "jellyseerr" }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
Seerr Database Secret Name
*/}}
{{- define "seerr.database.secretName" -}}
{{- if or (eq .Values.seerr.database.mode "cluster") (eq .Values.seerr.database.mode "standalone") }}
{{- printf "%s-seerr-db-app" .Release.Name }}
{{- else if .Values.seerr.database.external.existingSecret }}
{{- .Values.seerr.database.external.existingSecret }}
{{- else }}
{{- printf "%s-seerr-db" .Release.Name }}
{{- end }}
{{- end }}
