#!/usr/bin/env bash

set -euo pipefail

_env_err() {
  echo "environments.sh: $*" >&2
  return 1 2>/dev/null || exit 1
}

_gcloud_config_get() {
  gcloud config get-value "$1" 2>/dev/null || true
}

ENV_AGE_FILE="${ENV_AGE_FILE:-.env.age}"
AGE_SECRET_NAME="${AGE_SECRET_NAME:-age-master-secret}"
AGE_SECRET_VERSION="${AGE_SECRET_VERSION:-1}"

command -v age >/dev/null 2>&1 || _env_err "'age' command is required"
command -v gcloud >/dev/null 2>&1 || _env_err "'gcloud' command is required"

GCP_PROJECT_ID="${GCP_PROJECT_ID:-$(_gcloud_config_get project)}"

[ -f "$ENV_AGE_FILE" ] || _env_err "encrypted env file not found: $ENV_AGE_FILE"
[ -n "$GCP_PROJECT_ID" ] || _env_err "GCP_PROJECT_ID is required"
[ -n "$AGE_SECRET_NAME" ] || _env_err "AGE_SECRET_NAME is required"
[ -n "$AGE_SECRET_VERSION" ] || _env_err "AGE_SECRET_VERSION is required"

tmp_env="$(mktemp)"
tmp_age_identity="$(mktemp)"
trap "rm -f ${tmp_env} ${tmp_age_identity}" EXIT

gcloud secrets versions access "$AGE_SECRET_VERSION" \
  --project "$GCP_PROJECT_ID" \
  --secret "$AGE_SECRET_NAME" >"$tmp_age_identity"

age --decrypt --identity "$tmp_age_identity" --output "$tmp_env" "$ENV_AGE_FILE"

set -a
# shellcheck disable=SC1090
. "$tmp_env"
set +a
