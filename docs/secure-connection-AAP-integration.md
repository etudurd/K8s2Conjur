# 🛡️ Ansible ↔️ Conjur Integration Policy
Note: To enhance the security of the automation,** we leverage the established integration between Ansible Automation Platform (AAP) and Conjur.** This allows **AAP to securely retrieve required variables through a dedicated, non-admin identity** (ansible-automation-user). This identity is used to run Conjur commands and manage policies without exposing sensitive credential**s. All secrets needed by the automation have been securely onboarded into Conjur, enabling AAP to access them seamlessly. As a result, the number of input fields in the automation template has been reduced from 10 to just 4**, removing the need to manually enter Conjur credentials, OCP tokens, or other sensitive data, and significantly reducing the risk of exposure while simplifying the overall workflow.


# Step 1 Secure both AAP/AWX and the K8s2Conjur Automation

🔷⬇️ CyberArk Conjur Side ⬇️🔷

Login to Conjur by using the CLI

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

    # Permissions for the automation user to manage these variables
    - !permit
      role: !user AnsibleAutomationConjurUser
      privileges: [ read, update, execute ]
      resources: *variables

    # Permissions for the AAP host to only read and execute the variables
    - !permit
      role: !host AAP-node
      privileges: [ read, execute ]
      resources: *variables

    # Optional: internal group definition if you want to reuse inside this policy
    #- !group local-admins

    # Add the user to local-admins for future extensibility
    #- !grant
    #  role: !group local-admins
    #  members:
    #    - !user AnsibleAutomationConjurUser


```

And save the output as "aap-integration.yaml" and run the following command: 

```bash
conjur policy load -f aap-integration.yaml -b root
```

![AAP-integration](docs/images/1-s.png)


## 🔐 Grant Access to the AnsibleAutomationConjurUser to the JWT authenticator - which is linked to Root Branch, not incapsulated in the policy above (YAML)


```yaml
- !group admins
- !permit
  role: !group admins
  privileges:
    - create
    - update
    - read
  resources:
    - !policy root
- !grant
  role: !group admins
  members:
    - !user AnsibleAutomationConjurUser@AnsibleConjurIntegration
```                                         
