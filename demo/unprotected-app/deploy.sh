#!/bin/bash

set -e

# Prompt the user for namespace input
read -p "Enter the namespace to deploy the unprotected app: " NAMESPACE

echo "[INFO] Creating namespace if not exists..."
oc get project "$NAMESPACE" >/dev/null 2>&1 || oc new-project "$NAMESPACE"

# Export the namespace so envsubst can use it
export NAMESPACE

echo "[INFO] Applying secrets..."
envsubst < secrets.yaml | oc apply -f -

echo "[INFO] Applying service..."
envsubst < service.yaml | oc apply -f -

echo "[INFO] Applying deployment (Postgres + db-checker)..."
envsubst < deployment.yaml | oc apply -f -
envsubst < db-client.yaml | oc apply -f -

echo "[SUCCESS] All resources deployed to namespace: $NAMESPACE"
