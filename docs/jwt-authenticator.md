# Set Up JWT Authenticator for CyberArk Conjur

The JWT authentication is a generic, secure method for applications running on various platforms to authenticate to Conjur using a unique identity token or a third-party machine identity signed by a JWT provider.

This guide explains how to configure the JWT Authenticator in CyberArk Conjur to work with an OpenShift or Kubernetes cluster.

More details here. 


## 0. Prerequisites

We need to retrieve / query the Openshift cluster resources first.
This deployment guide is based on `jwks-uri` (when the Service Account Issuer Discovery service is not publicly available).

- Required CLI tools: `kubectl`, `curl`, and `jq`
- Required access: ClusterRole `system:service-account-issuer-discovery` or output from someone with this access

![Prerequisite output](../assets/images/c3a54909-7f51-4876-be23-7feb2b361de3.png)

## 1. Retrieve JWT Configuration

### A. Get JWKS
```bash
oc get --raw $(oc get --raw /.well-known/openid-configuration | jq -r '.jwks_uri') > jwks.json
```
![JWKS Output](../assets/images/e6c3cffd-e410-403a-b789-f447d1143cba.png)

### B. Check OpenID Config
```bash
oc get --raw /.well-known/openid-configuration
curl -k https://<your-cluster>/openid/v1/jwks
```
![Curl JWKS](../assets/images/583cce2d-4863-4a2c-804f-fde8d07bc64f.png)

### C. Extract API Endpoint
```bash
oc status | grep https
```
![API Status](../assets/images/0a149016-d063-4b89-9e2a-0f9cda588392.png)

## 2. Define the JWT Authenticator Policy
![JWT Policy](../assets/images/94436b0d-df6d-4623-b463-0593bf43b21f.png)

```bash
conjur policy load -f jwt-authn-automation.yml -b root
```

## 3. Extract Kubernetes JWT and Issuer

Run the following to retrieve the token and issuer:

```bash
oc get --raw $(oc get --raw /.well-known/openid-configuration | jq -r '.jwks_uri') > jwks.json
oc get --raw /.well-known/openid-configuration | jq -r '.issuer'
```
![JWT + Issuer](../assets/images/e9556e1d-a377-4733-a8bc-84c44e460dae.png)

## 4. Populate JWT Variables in Conjur

Transfer `jwks.json` to the Conjur CLI host, then run:

```bash
conjur variable set -i conjur/authn-jwt/dev-cluster-automation/public-keys -v '{"type":"jwks", "value":$(cat jwks.json)}'
conjur variable set -i conjur/authn-jwt/dev-cluster-automation/issuer -v https://kubernetes.default.svc
conjur variable set -i conjur/authn-jwt/dev-cluster-automation/token-app-property -v sub
conjur variable set -i conjur/authn-jwt/dev-cluster-automation/identity-path -v app-path
conjur variable set -i conjur/authn-jwt/dev-cluster-automation/audience -v https://conjur.host.name/
```
![Variable Set](../assets/images/324ae71f-b4ff-44ae-9678-3117c37d787c.png)

## 5. Allowlist the JWT Authenticator

```bash
export CONJUR_AUTHENTICATORS="authn,authn-jwt/dev-cluster-automation"
podman exec conjur evoke variable set CONJUR_AUTHENTICATORS "authn,authn-jwt/dev-cluster-automation"
```

## 6. Enable Seed Generation Service

Create the following policy file `seed-generation.yml`:

![Seed Policy](../assets/images/c993f76e-a4cc-4b2a-b2c2-59d918501dab.png)

```bash
conjur policy load -f seed-generation.yml -b root
```
