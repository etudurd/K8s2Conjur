# 🔐 K8s2Conjur Demo: From Exposed Secrets to Secure Workloads with CyberArk Conjur

This demo showcases how an "unprotected" Kubernetes or OpenShift application using hardcoded secrets can be automatically scanned, onboarded, and secured using **CyberArk Conjur** and the **Secrets Provider for Kubernetes (JWT authentication)**.

---

## 📥 Download the Unprotected App Demo

> ⚠️ The scripts use `oc` (OpenShift CLI) by default but can be easily modified to use `kubectl`. All deployment files (`yaml`) are compatible with both platforms.

```bash
curl -L -o K8s2Conjur-main.zip https://github.com/etudurd/K8s2Conjur/archive/refs/heads/main.zip
unzip K8s2Conjur-main.zip
cd K8s2Conjur-main/demo/unprotected-app
```

---

## ▶️ How to Run the Demo

### 0. Log in to your OpenShift cluster:

```bash
oc login --token=sha256~YOUR_TOKEN --server=https://api.YOUR_OCP_CLUSTER:6443
```

### 0.1 Make the scripts executable:

```bash
chmod +x deploy.sh cleanup.sh
```

### 1. Deploy the application:

```bash
./deploy.sh
```

You’ll be prompted to enter the target namespace (e.g., `tudor-automation-ns`).

![AAP-integration](/docs/images/uc1.png)
---

## 🧪 What's Inside the Demo

This demo application includes:

- A **PostgreSQL** container exposing 3 secrets as environment variables:
  - `DB_NAME`
  - `DB_USERNAME`
  - `DB_PASSWORD`
- A **client container** that connects to the database using these values from Kubernetes Secrets.

This setup reflects a common real-world misconfiguration, making it ideal for demonstrating automated secret onboarding.

---

## 🔍 Inspect the Running Application

### 2. Check the pods:

```bash
oc get pods -n tudor-automation-ns
```
 ![AAP-integration](/docs/images/uc2.png)

![AAP-integration](/docs/images/uc3.png)

### 3. View client logs:

```bash
oc logs pod/db-checker-XXXXXX -n tudor-automation-ns
```

![AAP-integration](/docs/images/uc4.png)

You will see the client successfully connecting to the DB using static Kubernetes Secrets.

![AAP-integration](/docs/images/uc5.png)
![AAP-integration](/docs/images/uc6.png)

---

## ✨ Apply Conjur Automation

### 4. Launch the AAP/AWX job template

Fill in the following fields:

- **Service Account**: e.g. `2025postgres-sa`
- **Deployment Name**: e.g. `postgres`
- **Namespace**: e.g. `tudor-automation-ns`
- **Authenticator ID**: as configured in your Conjur setup

![AAP-integration](/docs/images/uc7.png)

This automation will:
- Scan the workload and extract referenced secrets
- Onboard the workload identity to Conjur
- Create and upload secret variables
- Patch the deployment with a **Secrets Provider** sidecar
- Replace Kubernetes Secrets with dynamic Conjur references

![AAP-integration](/docs/images/uc8.png)
![AAP-integration](/docs/images/uc9.png)
![AAP-integration](/docs/images/uc10.png)

---

## ✅ What Happens After Automation

Once the Ansible job runs:

- ✅ Secrets Provider sidecar (`cyberark-secrets-provider`) is added to the pod
- 🔄 Secret environment variables are replaced with Conjur `conjur-map` references
- 🔐 Secrets are now securely pulled from Conjur using JWT
- 📜 Host and variable policies are automatically created and loaded

---

## 🔁 Test Dynamic Secret Rotation

Update the values of your secrets in Conjur, and observe the application update **in real-time** without restarts.

![AAP-integration](/docs/images/uc11.png)
![AAP-integration](/docs/images/uc12.png)

---

## 🧹 Clean Up the Demo

To remove the deployed resources:

```bash
./cleanup.sh
```

To remove policies and variables from Conjur:

### Sample `delete.yaml`

```yaml
- !delete 
  record: !variable secrets/postgres-OnboardedSecret/DB_NAME
- !delete 
  record: !variable secrets/postgres-OnboardedSecret/DB_PASSWORD
- !delete
  record: !variable secrets/postgres-OnboardedSecret/DB_USERNAME
- !delete
  record: !host app-path/system:serviceaccount:tudor-automation-ns:2025postgres-sa
- !delete
  record: !variable secrets/postgres-OnboardedSecret/conjur-map
```

Then run:

```bash
conjur policy update -f delete.yaml -b root
```

---

## 📚 Learn More

Check out the [docs/automation-flow.md](../docs/automation-flow.md) to understand the complete onboarding logic, flow, and security model.

---

**From hardcoded secrets ➜ to dynamic secret delivery — in one click. 🔐🚀**
