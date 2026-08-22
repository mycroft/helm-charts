#!/usr/bin/env bash
# Render every chart (defaults + each ci/*-values.yaml) and validate the output
# against the Kubernetes API schemas for a given version.
#
#   ./scripts/kubeconform.sh [k8s-version]
set -euo pipefail

K8S_VERSION="${1:-1.31.4}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

status=0

validate() {
  local chart="$1" label="$2"
  shift 2
  echo "==> ${chart} [${label}] against k8s ${K8S_VERSION}"
  if ! helm template release-name "$chart" "$@" \
    | kubeconform \
        -strict \
        -summary \
        -kubernetes-version "$K8S_VERSION" \
        -schema-location default \
        -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' \
        -; then
    status=1
  fi
}

for chart in charts/*/; do
  [ -f "${chart}Chart.yaml" ] || continue
  chart="${chart%/}"
  validate "$chart" defaults
  for values in "${chart}"/ci/*-values.yaml; do
    [ -f "$values" ] || continue
    validate "$chart" "$(basename "$values")" -f "$values"
  done
done

exit "$status"
