# Set Up JWT Authenticator for CyberArk Conjur

This guide explains how to configure the JWT Authenticator in CyberArk Conjur to work with an OpenShift or Kubernetes cluster.

## Before You Begin

 ![image](https://github.com/user-attachments/assets/fde7e9e7-4ff6-476b-9c52-946d9c833dfb)


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
