# K8s2Conjur
End-to-end automation to Discover, Onboard and Secure Kubernetes workloads and secrets with CyberArk Conjur via AAP.


K8s2Conjur/
├── docs/
│   ├── _index.md                ← Overview page (like a landing page)
│   ├── prerequisites.md         ← Tooling, cluster access, etc.
│   ├── jwt-authenticator.md     ← Step-by-step guide for setting up JWT
│   ├── secrets-provider.md      ← Guide for deploying Secrets Provider
│   ├── automation-flow.md       ← Ansible playbook and workflow explanation
│   └── troubleshooting.md       ← Common errors and fixes
├── automation/
│   ├── ansible/
│   │   ├── playbook.yml
│   │   └── requirements.yml
│   ├── policy/
│   │   ├── jwt-authn-automation.yml
│   │   └── seed-generation.yml
│   └── tools/
│       └── scanner.py
├── assets/
│   ├── images/
│   │   └── jwt-auth-flow.png
│   └── diagrams/
│       └── architecture.png
├── LICENSE
├── README.md
└── mkdocs.yml / config.toml      ← for MkDocs (or Hugo if you use a static site)
