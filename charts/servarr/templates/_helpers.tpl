{{/*
Seerr Database Host
*/}}
{{- define "seerr.database.host" -}}
{{- if eq .Values.seerr.database.mode "cluster" }}
{{- printf "%s-%s-rw" .Release.Name (.Values.seerr.database.cluster.name | default "seerr-db") }}
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
{{- .Values.seerr.database.external.port | default "5432" }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
Seerr Database Username
*/}}
{{- define "seerr.database.username" -}}
{{- if eq .Values.seerr.database.mode "cluster" }}
{{- .Values.seerr.database.auth.username | default "seerr" }}
{{- else if eq .Values.seerr.database.mode "external" }}
{{- .Values.seerr.database.auth.username }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
Seerr Database Name
*/}}
{{- define "seerr.database.name" -}}
{{- if or (eq .Values.seerr.database.mode "cluster") (eq .Values.seerr.database.mode "external") }}
{{- .Values.seerr.database.external.mainDatabase | default "jellyseerr" }}
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
{{- printf "%s-app" (.Values.seerr.database.cluster.name | default (printf "%s-seerr-db" .Release.Name)) }}
{{- end }}
{{- else }}
{{- if not .Values.seerr.database.auth.existingSecret }}
{{- fail "seerr.database.auth.existingSecret is required when seerr.database.mode is 'external'" }}
{{- end }}
{{- .Values.seerr.database.auth.existingSecret }}
{{- end }}
{{- end }}
