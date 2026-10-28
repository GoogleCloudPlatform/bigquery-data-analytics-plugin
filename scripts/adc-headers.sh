#!/usr/bin/env bash
set -euo pipefail
TOKEN="$(gcloud auth application-default print-access-token)"
QP="$(sed -n 's/.*"quota_project_id": *"\([^"]*\)".*/\1/p' ~/.config/gcloud/application_default_credentials.json)"
printf '{"Authorization":"Bearer %s","x-goog-user-project":"%s"}\n' "$TOKEN" "$QP"
