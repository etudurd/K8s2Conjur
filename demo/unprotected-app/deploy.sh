#!/bin/bash

set -e

read -p "Enter the namespace to deploy the unprotected app: " NAMESPACE

echo "[INFO] Creating namespace if not exists..."
oc get project "$NAMESPACE" >/dev/null 2>&1 || oc new-project "$NAMESPACE"

echo "[INFO] Applying secrets..."
oc apply -f secrets.yaml -n "$NAMESPACE"

echo "[INFO] Applying service..."
oc apply -f service.yaml -n "$NAMESPACE"

echo "[INFO] Applying deployment (Postgres + db-checker)..."
oc apply -f deployment.yaml -n "$NAMESPACE"
oc apply -f db-client.yaml  -n "$NAMESPACE"

echo "[SUCCESS] All resources deployed to namespace: $NAMESPACE"
