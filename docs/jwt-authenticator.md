# Set Up JWT Authenticator for CyberArk Conjur

The JWT authentication is a generic, secure method for applications running on various platforms to authenticate to Conjur using a unique identity token or a third-party machine identity signed by a JWT provider.

This guide explains how to configure the JWT Authenticator in CyberArk Conjur to work with an OpenShift or Kubernetes cluster.

More details [here](https://docs.cyberark.com/conjur-enterprise/latest/en/content/integrations/k8s-ocp/k8s-jwt-authn.htm?tocpath=Integrations%7COpenShift%252FKubernetes%7CAuthenticate%20OpenShift%252FKubernetes%7C_____2). 


## 0. Prerequisites

We need to retrieve / query the Openshift cluster resources first.
This deployment guide is based on `jwks-uri` (when the Service Account Issuer Discovery service is not publicly available).

- Required CLI tools: `kubectl` or `oc`, `curl`, and `jq`
- Required access: ClusterRole `system:service-account-issuer-discovery` or output from someone with this access
- !Replace "oc" commands with "kubectl" if you are using Openshift.


### 0.1 Retrieve JWT Configuration

#### A. Get JWKS and save it as "jwks.json"
```bash
oc get --raw $(oc get --raw /.well-known/openid-configuration | jq -r '.jwks_uri') > jwks.json
```

### B. Check OpenID Config and if there is an output being retrieved: 
```bash
oc get --raw /.well-known/openid-configuration
curl -k https://<your-cluster>/openid/v1/jwks
```
**If no output is returned, try the following:**

### C. Manually Extract the OpenShift API Endpoint
```bash
oc status | grep https
```
Copy the HTTPS endpoint (e.g., https://api.<><>:6443) and append /openid/v1/jwks to it — the full URL should look like: https://api.<><>:6443/openid/v1/jwks

```bash
curl -k https://api.<><>:6443/openid/v1/jwks
```
Check if the JWKS response is returned.

## 2. Define the JWT Authenticator Policy

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
