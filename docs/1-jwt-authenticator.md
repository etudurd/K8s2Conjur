# Set Up JWT Authenticator for CyberArk Conjur

The JWT authentication is a generic, secure method for applications running on various platforms to authenticate to Conjur using a unique identity token or a third-party machine identity signed by a JWT provider.

This guide explains how to configure the JWT Authenticator in CyberArk Conjur to work with an OpenShift or Kubernetes cluster.

More details [here](https://docs.cyberark.com/conjur-enterprise/latest/en/content/integrations/k8s-ocp/k8s-jwt-authn.htm?tocpath=Integrations%7COpenShift%252FKubernetes%7CAuthenticate%20OpenShift%252FKubernetes%7C_____2). 

**🔴⬇️	 **Kubernetes/Openshift Side** ⬇️🔴**

## 0. Prerequisites

We need to retrieve / query the Openshift cluster resources first.
This deployment guide is based on `jwks-uri` (when the Service Account Issuer Discovery service is not publicly available).

- Required CLI tools: `kubectl` or `oc`, `curl`, and `jq`
- Required access: ClusterRole `system:service-account-issuer-discovery` or output from someone with this access
- !Replace "oc" commands with "kubectl" if you are using Openshift.

<details>
### <summary> **0.1 Retrieve JWT Configuration** </summary>

##### A. Get JWKS and save it as "jwks.json"
```bash
oc get --raw $(oc get --raw /.well-known/openid-configuration | jq -r '.jwks_uri') > jwks.json
```

##### B. Check OpenID Config and if there is an output being retrieved: 
```bash
oc get --raw /.well-known/openid-configuration
curl -k https://<your-cluster>/openid/v1/jwks
```
**If no output is returned, try the following:**

##### C. Manually Extract the OpenShift API Endpoint
```bash
oc status | grep https
```
Copy the HTTPS endpoint (e.g., https://api.<><>:6443) and append /openid/v1/jwks to it — the full URL should look like: https://api.<><>:6443/openid/v1/jwks

```bash
curl -k https://api.<><>:6443/openid/v1/jwks
```
JWKS response is returned? -> If Yes, proceed with the next steps. 

</details>

**🔷⬇️	 **CyberArk Conjur Side** ⬇️🔷**

## 1. Define the JWT Authenticator Policy
```yaml
- !policy
  id: conjur/authn-jwt/dev-cluster-automation
  body:
    - !webservice
 
    # Uncomment one of following variables depending on the public availability
    # of the Service Account Issuer Discovery service in Kubernetes
    # If the service is publicly available, uncomment 'jwks-uri'.
    # If the service is not available, uncomment 'public-keys'
    # - !variable jwks-uri
    - !variable public-keys
 
    - !variable issuer
    - !variable token-app-property
    - !variable identity-path
    - !variable audience
    
    # Group of applications that can authenticate using this JWT Authenticator
    - !group apps
   
    - !permit
      role: !group apps
      privilege: [ read, authenticate ]
      resource: !webservice
   
    - !webservice status
   
    # Group of users who can check the status of the JWT Authenticator
    - !group operators
   
    - !permit
      role: !group operators
      privilege: [ read ]
      resource: !webservice status
```
Save the yaml (jwt-authn-automation.yml) and Run using the Conjur CLI: 

```bash
conjur policy load -f jwt-authn-automation.yml -b root
```
**🔴⬇️	 **Kubernetes/Openshift Side** ⬇️🔴**

## 2. Extract Kubernetes JWT and Issuer

Run the following to retrieve the token and issuer:

```bash
oc get --raw $(oc get --raw /.well-known/openid-configuration | jq -r '.jwks_uri') > jwks.json
oc get --raw /.well-known/openid-configuration | jq -r '.issuer'
```

**🔷⬇️	 **CyberArk Conjur Side** ⬇️🔷**

## 3. Populate JWT Variables in Conjur

Transfer `jwks.json` to the Conjur CLI host, then run:

```bash
conjur variable set -i conjur/authn-jwt/dev-cluster-automation/public-keys -v "{\"type\":\"jwks\", \"value\":$(cat jwks.json)}"
conjur variable set -i conjur/authn-jwt/dev-cluster-automation/issuer -v https://kubernetes.default.svc
conjur variable set -i conjur/authn-jwt/dev-cluster-automation/token-app-property -v "sub"
conjur variable set -i conjur/authn-jwt/dev-cluster-automation/identity-path -v app-path
conjur variable set -i conjur/authn-jwt/dev-cluster-automation/audience -v "https://conjur.host.name/"

```


**🔷⬇️	 **CyberArk Conjur Side** ⬇️🔷**

## 5. Allowlist the JWT Authenticator

On the same host, where Conjur container is deployed. (You also can use conjur.yml as an alternative)
```bash
CONJUR_AUTHENTICATORS=authn,authn-jwt/dev-cluster-automation
podman exec conjur evoke variable set CONJUR_AUTHENTICATORS authn,authn-jwt/dev-cluster-automation
```

**🔷⬇️	 **CyberArk Conjur Side** ⬇️🔷**

## 6. Enable Seed Generation Service

Create the following policy file `seed-generation.yml`:

```yaml
---
# =================================================
# == Register the seed generation service
# =================================================
- !policy
  id: conjur/seed-generation
  body:
  # This webservice represents the Seed service API
  - !webservice

  # Hosts that can generate seeds become members of the
  # `consumers` group.
  - !group consumers

  # Authorize `consumers` to request seeds
  - !permit
    role: !group consumers
    privilege: [ "execute" ]
    resource: !webservice

```


And Run:

```bash
conjur policy load -f seed-generation.yml -b root
```
