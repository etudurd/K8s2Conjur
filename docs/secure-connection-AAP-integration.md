# 🛡️ Ansible ↔️ Conjur Integration Policy

This document describes a Conjur policy used to securely integrate an Ansible Automation Platform (AAP) environment with CyberArk Conjur. It defines identities, secrets, and permissions required for automated access to sensitive data.

---

## 🔐 Conjur Policy (YAML)

```yaml

- !policy
  id: AnsibleConjurIntegration
  body:
    # Define the human identity (user) that automation uses to authenticate to Conjur via API key
  - !user AnsibleAutomationConjurUser

    # Define the machine identity (host) representing the AAP node or execution environment
  - !host AAP-node

    # Define variables that store credentials and configuration values
  - &variables
    - !variable ocp_api_host        # OpenShift or Kubernetes API endpoint
    - !variable conjur_account      # Conjur account name (e.g., 'default')
    - !variable conjur_host         # Conjur appliance URL
    - !variable conjur_username     # Conjur username used by automation
    - !variable conjur_password     # Conjur user API key
    - !variable ocp_token           # OpenShift Web Console Bearer token

    # Declare the actual variables
    # - *variables

    # Permissions for user to manage variables
  - !permit
    role: !user AnsibleAutomationConjurUser
    privileges: [ read, update, execute ]
    resources: *variables

    # Grant read & execute permissions to the AAP host to consume the secrets
  - !permit
    role: !host AAP-node
    privileges: [ read, execute ]
    resources: *variables

    # Create admin group
    # - !group admins

    # Add the automation user to admin group
  - !grant
    role: !group admins
    members:
      - !user AnsibleAutomationConjurUser

    # Allow admin group to manage root policy space
    # - !permit
    # role: !group admins
    #privileges: [ create, update, read ]
    #resource: !policy root

```
