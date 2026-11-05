#!/usr/bin/env bash
set -euo pipefail

TOKEN="$(gcloud auth application-default print-access-token)"
printf '{"Authorization":"Bearer %s"}\n' "$TOKEN"
