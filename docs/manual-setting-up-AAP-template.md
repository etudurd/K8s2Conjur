# ⚙️ Configuring the Automation

Supposing the Plugin was defined and the connection between AAP and Conjur was secured.

# Step 1 Create a Project in AAP/AWX

**🔴⬇️	 **Ansible Side** ⬇️🔴**

Navigate to **Resources -> Projects** and press **Add** 

<img src="images/11-s.png" alt="AAP Integration" width="420"/>

```yaml

Name: K8s2Conjur Automation Project 2025
Description: E2E Automation Conjur+AAP+OC Tudor Urdes
Organization: Conjur Demo # replace with yours
Source Control URL: ProjectAddress

```
<img src="images/12-s.png" alt="AAP Integration" width="420"/>


# Step 2 Define the Template

Navigate to **Resources -> Templates** and press **Add** 

<img src="images/13-s.png" alt="AAP Integration" width="420"/>

```yaml

Name: K8s2Conjur Automation Project Scan Template 2025
Inventory: Demo Inventory #replace with your own inventory
Description: E2E Automation Conjur+AAP+OC Tudor Urdes
Playbook: K8s2Conjur.yaml
Credentials: Press on the loop -> Selected Category -> "Conjur Automation Settings" -> "Conjur AAP Automation Variables" 

```
<img src="images/14-s.png" alt="AAP Integration" width="250"/>

**Output**

<img src="images/15-s.png" alt="AAP Integration" width="420"/>

# Step 3 Run the Automation and fill the requested details


