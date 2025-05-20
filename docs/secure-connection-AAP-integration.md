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

![AAP-integration](images/1-s.png)


Save the output. As we can observe, **two API keys are generated: one for configuring the Ansible plugin to connect with the Conjur Leader/Follower. **(host:AnsibleConjurIntegration/AAP-node), a**nd another for the automation itself to interact with the Conjur API and onboard the scanned Kubernetes deployments** (user:AnsibleAutomationConjurUser@AnsibleConjurIntegration). 

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

Save the policy above as: ** aap-user-jwt-access.yaml ** and run:
```bash
conjur policy load -f aap-user-jwt-access.yaml -b root
```

# Step 2 Inject the connection values to the variables created above:

From the Conjur CLI run the following commands:

```bash

conjur variable set -i AnsibleConjurIntegration/conjur_account -v poc-conjur    #replace poc-conjur with your Conjur account name

conjur variable set -i AnsibleConjurIntegration/conjur_host -v ec2<>.compute.amazonaws.com  #replace with your Conjur Leader/Follower DNS address

#replace with the API key resulted after applying the first policy - associated with the user AnsibleAutomationConjurUser@AnsibleConjurIntegration

conjur variable set -i AnsibleConjurIntegration/conjur_password -v 2041APIKEY  

conjur variable set -i AnsibleConjurIntegration/conjur_username -v AnsibleAutomationConjurUser@AnsibleConjurIntegration

conjur variable set -i AnsibleConjurIntegration/ocp_api_host -v api.cluster.emea-lab.cybr:6443   #replace with your Openshift/K8 Server address

conjur variable set -i AnsibleConjurIntegration/ocp_token -v sha256~i8aU9jMD8Lu_AnFqC36_MfUlktGI_r6G0Ce5ziWWLbg  #replace with your Openshift/K8 API token



