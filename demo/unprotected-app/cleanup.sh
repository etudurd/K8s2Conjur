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

echo "[INFO] Deleting roles and role bindings (if any)..."
oc delete role db-checker-role -n "$NAMESPACE" --ignore-not-found || true
oc delete rolebinding db-checker-binding -n "$NAMESPACE" --ignore-not-found || true

echo "[INFO] Attempting to remove Reloader annotation from your deployment (if exists)..."
oc patch deployment postgres -n "$NAMESPACE" \
  --type=json \
  -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/reloader.stakater.com~1auto"}]' \
  || true

# ---------------------------
# OPTIONAL: UNINSTALL RELOADER (commented out for shared environments)
# ---------------------------
# echo "[INFO] WARNING: The following block would uninstall Reloader. It's currently commented out."
# echo "[INFO] Uncomment ONLY if you're sure no one else uses Reloader in this cluster."
#
# read -p "Do you want to uninstall Reloader and delete the 'reloader' namespace? [y/N]: " DELETE_RELOADER
# if [[ "$DELETE_RELOADER" == "y" || "$DELETE_RELOADER" == "Y" ]]; then
#   echo "[INFO] Uninstalling Reloader Helm release..."
#   helm uninstall reloader -n reloader || echo "[INFO] Helm release not found or already removed."
#
#   echo "[INFO] Deleting 'reloader' namespace..."
#   oc delete namespace reloader --ignore-not-found
#   echo "[INFO] ✅ Reloader fully removed."
# else
#   echo "[INFO] Skipped Reloader uninstall."
# fi

echo "[SUCCESS] Cleaned up all associated resources in: $NAMESPACE"
