#!/bin/bash

set -e

read -p "Enter the namespace to clean up the unprotected app: " NAMESPACE

echo "[INFO] Deleting deployments..."
oc delete deployment postgres -n "$NAMESPACE" --ignore-not-found
oc delete deployment db-checker -n "$NAMESPACE" --ignore-not-found

echo "[INFO] Deleting service..."
oc delete svc postgres -n "$NAMESPACE" --ignore-not-found

echo "[INFO] Deleting secrets..."
oc delete secret postgres-secrets -n "$NAMESPACE" --ignore-not-found

echo "[INFO] Deleting service account..."
oc delete serviceaccount 2025postgres-sa -n "$NAMESPACE" --ignore-not-found

echo "[INFO] Deleting config map..."
oc delete configmap db-checker-code -n "$NAMESPACE" --ignore-not-found

echo "[INFO] Deleting Automation config map..."
oc delete configmap follower-cm -n "$NAMESPACE" --ignore-not-found

echo "[INFO] Deleting roles and role bindings (if any)..."
oc delete role db-checker-role -n "$NAMESPACE" --ignore-not-found || true
oc delete rolebinding db-checker-binding -n "$NAMESPACE" --ignore-not-found || true

oc patch deployment postgres -n "$NAMESPACE" \
  --type=json \
  -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/reloader.stakater.com~1auto"}]' \
  || echo "[INFO] Annotation not found or already removed. Skipping."


# Namespace where Reloader is deployed
RELOADER_NAMESPACE="tudor-automation-ns"

echo "[INFO] 🚨 You are about to uninstall the Reloader Helm release and delete the namespace: '$RELOADER_NAMESPACE'."
read -p "Are you sure? This action is irreversible. Type 'yes' to continue: " CONFIRM

if [[ "$CONFIRM" == "yes" ]]; then
  echo "[INFO] Uninstalling Reloader Helm release..."
  helm uninstall reloader -n "$RELOADER_NAMESPACE" || echo "[INFO] Reloader Helm release not found or already removed."

  echo "[INFO] Deleting namespace '$RELOADER_NAMESPACE'..."
  oc delete namespace "$RELOADER_NAMESPACE" --ignore-not-found

  echo "[INFO] ✅ Reloader fully uninstalled and namespace deleted."
else
  echo "[INFO] ❌ Operation cancelled. Reloader not uninstalled."
fi
