# Set Up JWT Authenticator for CyberArk Conjur

This guide explains how to configure the JWT Authenticator in CyberArk Conjur to work with an OpenShift or Kubernetes cluster.

## Before You Begin


## Example: JWT Authenticator Policy

Below is an example Conjur policy for enabling JWT authentication:

```yaml
- !policy
  id: conjur/authn-jwt/dev-cluster-automation
  body:
    - !webservice
    - !variable public-keys
    - !variable issuer
    - !variable token-app-property
    - !variable identity-path
    - !variable audience
