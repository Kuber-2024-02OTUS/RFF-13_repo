{{/*
Expand the name of the chart.
*/}}
{{- define "template-chart-sps.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}
