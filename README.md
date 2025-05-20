# <img src="docs/images/logo-placeholder1.png" alt="Project Logo Placeholder" width="420"/>

**K8s2Conjur is a fully automated onboarding framework** that scans Kubernetes or OpenShift workloads and securely integrates both applications and secrets into **CyberArk Conjur Enterprise**.

This solution goes beyond secret injection — it dynamically **onboards the application itself** into Conjur by:
- 🔍 Scans Kubernetes/OpenShift workloads for referenced secrets (env vars, volumes)
- 🏗️ Dynamically generates a **dedicated Host identity policy** in Conjur to represent the workload.
- 🔐 Onboards discovered secrets into Conjur with their initial values.
- 📜 Creates and loads granular Conjur policies: variables, permissions, access rules.
- 🧩 Injecting the Secrets Provider sidecar to fetch secrets securely at runtime using **JWT-based authentication**
- ⚙️ Automatically updating deployments with Conjur integration patches


K8s2Conjur performs the following steps
- 🔍 Scans Kubernetes/OpenShift workloads for referenced secrets (env vars, volumes)
- 🔐 Onboards discovered secrets into Conjur with their initial values
- 🏗️ Dynamically generates a **dedicated Host identity and policy** in Conjur to represent the workload
- 📜 Creates and loads granular Conjur policies: variables, permissions, access rules
- ✅ Create and apply a ConfigMap in the app namespace with Conjur configuration (appliance URL, Conjur public cert, authenticator ID, etc.).
- 🛠️ Automatically patch the Kubernetes deployment to replace hardcoded secrets with Conjur references and inject the CyberArk Secrets Provider as a sidecar.
- ✅ Create and bound RBAC resources (Role & RoleBinding) that give the Secrets Provider the ability to read and update Kubernetes secrets in the application
- ✅ Ensures the workload fetches secrets securely at runtime — no hardcoded values or manual steps

---

## 🖼️ Project Overview

![Project Logo Placeholder](images/logo-placeholder.png)

![Architecture Diagram Placeholder](images/architecture-placeholder.png)

![Onboarding Flow Placeholder](images/onboarding-steps-placeholder.png)

![Integration Result Screenshot](images/integration-placeholder.png)

---

## ✅ Core Components

- ✅ Access to an OpenShift or Kubernetes cluster  
  - The automation assumes permissions to create:  
    - Deployments  
    - ServiceAccounts  
    - RoleBindings  
    - Secrets

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

## 🧰 Machine Requirements (AAP EE or Execution Node)

- `conjur` CLI installed  
- `kubectl` or Kubernetes-compatible API client  
- Conjur credentials with the `conjur-policy-loader` role  

📘 See: [Conjur CLI Setup Guide](https://docs.cyberark.com/ConjurCloud-latest/en/Content/ConjurCLI/cli-install.htm)

---

## 🌐 Network Requirements

| Component                  | Needs Access To | Port | Purpose                                 |
|---------------------------|-----------------|------|-----------------------------------------|
| AAP                       | Conjur          | 443  | Secrets injection, policy operations    |
| AAP                       | OpenShift API   | 443  | Deployment control via API              |
| OpenShift/K8s             | Conjur          | 443  | Secrets Provider JWT-based authentication |

✅ Ensure **DNS resolution** works for both the OpenShift API and Conjur endpoints **from both AAP and OpenShift**.

---

## 🏗️ Optional: In-Cluster Execution Environment

Use Ansible Execution Environments **inside OpenShift** if:
- You want to run automation from within the cluster  
- You want to avoid exposing the OpenShift API externally  
- AAP is deployed as a workload in OpenShift  

---

## 📦 Required Ansible Collection

Install the `kubernetes.core` collection either via:

`requirements.yml`:
```yaml
collections:
  - name: kubernetes.core
or manually:

bash
Copy
Edit
ansible-galaxy collection install kubernetes.core
Then in your playbook:

yaml
Copy
Edit
collections:
  - kubernetes.core
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

But for most use cases, manual copy-paste of the token is sufficient and secure.

📘 Documentation
📄 Additional guides and walkthroughs:

Secure AAP Integration

JWT Authenticator Setup

🌍 GitHub Pages Site (coming soon)
Your documentation will be available here:
📘 https://etudurd.github.io/K8s2Conjur/

🤝 Contributing
Have feedback or want to add support for other clusters?
Feel free to open a pull request or issue.

📜 License
This project is licensed under the MIT License.

python
Copy
Edit

---

Let me know if you'd like:
- A `docs/index.md` generated from this for GitHub Pages
- A styled banner/logo image
- The 4 placeholder images pre-generated as PNGs (empty wireframes or boxes)

I'm happy to help finish the launch kit.









```bash
ansible-playbook -i inventory playbook.yml
