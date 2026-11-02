#!/usr/bin/env bash
set -euo pipefail

TOKEN="$(gcloud auth application-default print-access-token)"

# Respect GOOGLE_APPLICATION_CREDENTIALS if set, otherwise use default path
ADC_FILE="${GOOGLE_APPLICATION_CREDENTIALS:-$HOME/.config/gcloud/application_default_credentials.json}"
QP=""

# Safely extract the project without breaking if the file doesn't exist
if [[ -f "$ADC_FILE" ]]; then
  QP="$(grep -o '"quota_project_id":[[:space:]]*"[^"]*"' "$ADC_FILE" | awk -F'"' '{print $4}' || true)"
fi

# Fallback to the configured default project if no quota project was found
if [[ -z "$QP" ]]; then
  QP="$(gcloud config get-value project 2>/dev/null || echo "")"
fi

printf '{"Authorization":"Bearer %s","x-goog-user-project":"%s"}\n' "$TOKEN" "$QP"