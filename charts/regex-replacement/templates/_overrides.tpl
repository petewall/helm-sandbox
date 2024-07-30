{{- define "configOverride" -}}
  {{- $config := .config -}}
  {{- range $override := .Values.configOverrides -}}
    {{- $componentStart := (printf "%s\\s+\"%s\"" $override.type $override.name) }}
    {{- if regexMatch $componentStart $config -}}
      {{ $config = regexReplaceAll (printf "(%s) {\\.*}" $componentStart) $config (printf "${1} {\n  %s\n}" $override.replacement) }}
    {{- else -}}
      {{- fail (printf "Unable to find component %s \"%s\"" $override.type $override.name) -}}
    {{- end -}}
  {{- end -}}
  {{ $config }}
{{- end -}}
