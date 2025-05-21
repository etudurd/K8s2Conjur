# <img src="docs/images/logo-placeholder-short.png" alt="Project Logo Placeholder" width="725"/>

**K8s2Conjur is a fully automated onboarding framework** that scans Kubernetes or OpenShift workloads and securely integrates both applications and secrets into **CyberArk Conjur Enterprise**.

K8s2Conjur performs the following steps
- 🔍 Scans workloads (Deployments, StatefulSets) for secrets referenced via environment variables and volumes
- 🔐 Onboards discovered secrets into Conjur with their initial values
- 🏗️ Dynamically generates a **dedicated Host identity and policy** in Conjur to represent the workload
- 📜 Dynamically builds and loads Conjur policies including:
      Variables for each secret
      Access rules linking the workload identity to its secrets
      Scoped permissions for least privilege
- ✅ Create and apply a ConfigMap in the app namespace with Conjur configuration (appliance URL, Conjur public cert, authenticator ID, etc.).
- 🛠️ Automatically patch the Kubernetes deployment to replace hardcoded secrets with Conjur references and inject the CyberArk Secrets Provider as a sidecar.
- 🔐 Create and bound RBAC resources (Role & RoleBinding) that give the Secrets Provider the ability to read and update Kubernetes secrets in the application
- 🔁 Delivers secrets securely both at startup and at runtime via JWT-based authentication using the CyberArk Secrets Provider, which runs continuously alongside 
  the application (side-car container). No hardcoded credentials, no manual secret management required.

📘 Official Documentation

  [What is CyberArk Conjur Enterprise?](https://docs.cyberark.com/conjur-enterprise/latest/en/content/enterprise/enterprise_vs_opensource.htm?tocpath=Get%20started%7C_____3)  
  
  [OpenShift/Kubernetes Integration](https://docs.cyberark.com/conjur-enterprise/latest/en/content/integrations/k8s-ocp/k8s_lp.htm?tocpath=Integrations%7COpenShift%252FKubernetes%7C_____0) 
  
  [JWT Authentication](https://docs.cyberark.com/conjur-enterprise/latest/en/content/operations/services/cjr-authn-jwt-lp.htm?tocpath=Integrations%7CJWT%20Authentication%7C_____0)
  
  [JWT-based Kubernetes authentication](https://docs.cyberark.com/conjur-enterprise/latest/en/content/integrations/k8s-ocp/k8s-jwt-authn.htm)
  
  [SecretsProvider and other methods to securely fetch secrets in K8s; Set up workloads (JWT-based authn)](https://docs.cyberark.com/conjur-enterprise/latest/en/content/integrations/k8s-ocp/k8s-jwt-set-up-apps.htm?tocpath=Integrations%7COpenShift%252FKubernetes%7CApp%20owner%253A%20Set%20up%20workloads%20in%20Kubernetes%7CSet%20up%20workloads%20(JWT-based%20authn)%7C_____0)
  
## 🖼️ Project Overview & Architecture
<details> 
  <summary><><><>Click to expand<><><></summary>

---
## Features: Before and After using the automation
<img src="docs/images/manual.png" alt="Project Logo Placeholder" width="625"/>
<img src="docs/images/before-after.png" alt="Project Logo Placeholder" width="625"/>

## Steps & Simplified Architecture 

<img src="docs/images/steps.png" alt="Project Logo Placeholder" width="850"/>
<img src="docs/images/steps-a.png" alt="Project Logo Placeholder" width="850"/>

---

</details>

## Prequisites 
<details> 
  <summary><><><>Click to expand<><><></summary>
    
## ✅ Core Components

-  Access to an OpenShift or Kubernetes cluster  
  - The automation assumes permissions to create:  
    - Deployments  
    - ServiceAccounts  
    - RoleBindings  
    - Secrets
-	The K8s/OC user if he doesn’t have cluster role permissions (super-user) he needs at least to have the following role added:
**  system:service-account-issuer-discovery (ClusterRole permission) **

## 🧰 Machine Requirements (AAP EE or Execution Node)

- `conjur` CLI installed  
- `kubectl\oc' or Kubernetes-compatible API client  
-  Conjur admin access for initial configuration.  

📘 See: [Conjur CLI Setup Guide]([https://docs.cyberark.com/ConjurCloud-latest/en/Content/ConjurCLI/cli-install.htm](https://docs.cyberark.com/conjur-enterprise/latest/en/content/developer/cli/cli-setup.htm?TocPath=Developer%7CConjur%20CLI%7C_____1)

- ✅ Ansible Automation Platform (AAP) or AWX operational
- ✅ CyberArk Conjur Enterprise with:
  - ✅ **JWT Authenticator enabled and configured** (📌 **one-time setup** per cluster — see [docs/jwt-authenticator.md](docs/jwt-authenticator.md))
  - ✅ A **dedicated non-admin Conjur identity** for the automation (`ansible-automation-user`)
  - ✅ Secrets such as tokens, URLs, and credentials stored as Conjur variables

---

## 🔐 Security Best Practices

- Use a **dedicated Conjur Host identity** for automation access  
- Store sensitive values securely in Conjur:
  - OpenShift/Kubernetes Bearer token
  - API Server endpoint
  - Conjur identity API key
- ✅ Sync those values into AAP using the **official Conjur-AAP integration**
- 📌 The JWT authenticator setup is a required **manual first step per cluster**, and **Step 2** (identity & token injection) is designed as a security layer to **reduce the attack surface** while leveraging secure token fetching

---

---

## 🌐 Network Requirements

| Component                  | Needs Access To | Port | Purpose                                 |
|---------------------------|-----------------|------|-----------------------------------------|
| AAP                       | Conjur          | 443  | Secrets injection, policy operations    |
| AAP                       | OpenShift API   | 443  | Deployment control via API              |
| OpenShift/K8s             | Conjur          | 443  | Secrets Provider JWT-based authentication |

✅ Ensure **DNS resolution** works for both the OpenShift API and Conjur endpoints **from both AAP and OpenShift**.

---

---

## 📦 Required Ansible Collection

Install the `kubernetes.core` collection either via:

`requirements.yml`:
```yaml
collections:
  - name: kubernetes.core

or manually:

```bash
ansible-galaxy collection install kubernetes.core
```

🔑 Retrieve OpenShift API URL & Token
Login to the OpenShift Web Console

Click your user menu → Copy Login Command

Extract:

--token=... → Bearer token

--server=https://... → API URL

Identify your target namespace/project

🔄 Optional: Automate Token Handling
You can automate login or rotate tokens using:

ServiceAccount tokens with projected audiences

oc login automation

Web console script extraction

But for most use cases, manual copy-paste of the token is sufficient for the first setup.

</details>

## TL;DR —  Deployment of `K8s2Conjur` Automation
<details>
  <summary><><><>Click to expand<><><></summary>

You can deploy this automation in minutes by either:
    
- **Cloning this repository locally** and importing it into your AAP/AWX project, **OR**
- Referencing the **public GitHub repository** directly as the source in your AAP project.

---
### 🔧 Required One-Time Preparations

#### 1. ✅ Deploy JWT Authenticator (Manually)

- This is a *security requirement* I used to isolate authentication per cluster. (1 JWT Authn required per K8s Cluster)
- It’s a **one-time setup** and should be created manually for each Kubernetes/OCP cluster.
- Follow the copy-paste-friendly guide here:  
  📄 [`docs/1-jwt-authenticator.md`](docs/1-jwt-authenticator.md)

---
#### 2. 🔐 Secure Connection Between AAP and Conjur

- Also a **one-time process** to safely onboard variables like:
  - `conjur_user` / `conjur_password`
  - `ocp_api_host`, `ocp_token`
- These are securely fetched using a **dedicated identity** (`ansible-automation-user`) to avoid exposing sensitive data.
- As a result, the AAP job template has been simplified from **10 input fields down to 4**.
- Full guide available at:  
  📄 [`docs/2-secure-connection-AAP-integration.md`](docs/2-secure-connection-AAP-integration.md)

---
#### 3. 📦 Set Up AAP Project, Job Template & Survey

- Follow this **one-time setup guide** to manually configure the job template, project, and survey:  
  📄 [`docs/3-improved-manual-setting-up-AAP-template.md`](docs/3-improved-manual-setting-up-AAP-template.md)
- *(An automated installer is coming soon.)*

---
#### ▶️ Run the Automation

Once the setup above is complete, **run** the main playbook:

```bash
From the AAP/AWX GUI -> Template
```
---

</details>



#### ⚠️ Disclaimer
This project is provided for demonstration and educational purposes only.  
It is not officially supported by CyberArk. Use at your own risk and ensure proper validation before deploying in production environments.

🤝 Contributing
Have feedback or want to add support for other clusters?
Feel free to open a pull request or issue.

📜 License
This project is licensed under the MIT License.

