{{- define "penpot.imageConfig" -}}
{{- $imageTag := .tag | toString }}
{{- $updateStrategy := .strategy }}
{{- $imageName := .repository }}
{{- if not $updateStrategy }}
  {{- if or (eq $imageTag "latest") (hasSuffix "-latest" $imageTag) }}
    {{- $updateStrategy = "digest" }}
  {{- else if regexMatch "^[0-9]+\\.[0-9]+\\.[0-9]+$" $imageTag }}
    {{- $updateStrategy = "semver" }}
    {{- $parts := regexSplit "\\." $imageTag -1 }}
    {{- $major := index $parts 0 }}
    {{- $minor := index $parts 1 }}
    {{- $imageName = printf "%s:%s.%s.x" .repository $major $minor }}
  {{- end }}
{{- else if and (eq $updateStrategy "semver") .tag }}
  {{- if regexMatch "^[0-9]+\\.[0-9]+\\.[0-9]+$" $imageTag }}
    {{- $parts := regexSplit "\\." $imageTag -1 }}
    {{- $major := index $parts 0 }}
    {{- $minor := index $parts 1 }}
    {{- $imageName = printf "%s:%s.%s.x" .repository $major $minor }}
  {{- else }}
    {{- $imageName = printf "%s:%s" .repository $imageTag }}
  {{- end }}
{{- else if .tag }}
  {{- $imageName = printf "%s:%s" .repository $imageTag }}
{{- end }}
{{- printf "%s|%s" $imageName $updateStrategy }}
{{- end }}
