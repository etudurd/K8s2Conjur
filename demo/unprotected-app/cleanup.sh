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

echo "[SUCCESS] Cleaned up all associated resources in: $NAMESPACE"
