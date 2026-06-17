# End-to-End Infrastructure Automation at Scale: Provisioning & Configuration using Terraform, Ansible and AWS

### Provision and configure different-sized AWS environments
(dev / staging / prod) from a **single codebase** using Terraform workspaces, reusable modules, remote state with locking, and Ansible for configuration management — with secrets handled through AWS Secrets Manager and **zero static credentials**.

<img width="1456" height="884" alt="image" src="https://github.com/user-attachments/assets/ef88f5b2-72d1-4fad-96aa-c85406571fcf" />

---

## What This Project Does

One Terraform codebase provisions a complete environment whose size is decided by the workspace you select:

| Environment | EC2 | S3 | DynamoDB |
|-------------|-----|----|----------|
| `dev`       | 2   | 1  | 1        |
| `stag`      | 3   | 1  | 1        |
| `prod`      | 4   | 2  | 2        |

<img width="1456" height="884" alt="image" src="https://github.com/user-attachments/assets/dc3277ae-96b5-436f-9074-5b28bcc316f8" />


Then **Ansible** connects to every server and configures them in parallel (installs packages, sets up nginx, deploys a landing page) — pulling the SSH key from **AWS Secrets Manager** at runtime.

---

## The Problem It Solves

Manually managing multiple environments leads to:

- **State chaos** — local state files that can't be shared and get corrupted when two people apply at once.
- **Secrets in git** — SSH keys and credentials accidentally committed.
- **Manual server setup** — SSH-ing into each box by hand, inconsistently.

## How This Project Resolves It

| Problem | Solution | How |
|--------|----------|-----|
| Repeated resource code | **Reusable modules** (ec2/s3/dynamodb) | Write each resource once, reuse everywhere |
| Lost / conflicting state | **S3 remote backend** | Central, durable, encrypted state |
| Concurrent-apply corruption | **DynamoDB state locking** | A lock blocks simultaneous applies |
| Secrets in source control | **AWS Secrets Manager + IAM** | SSH key stored in AWS, fetched at runtime; no keys in git |
| Manual, inconsistent config | **Ansible roles** | One playbook configures all servers identically |

---

##  Architecture

<img width="944" height="528" alt="architecture-flow" src="https://github.com/user-attachments/assets/d08c1fe8-405b-4ec3-849d-39a5c61db263" />


---

## Why These Services / Tools

| Service / Tool | Why it's used |
|----------------|---------------|
| **Terraform** | Infrastructure as Code — declarative, repeatable, version-controlled provisioning |
| **Terraform Workspaces** | Run the same code for many environments, each with isolated state |
| **Terraform Modules** | DRY, reusable building blocks (ec2/s3/dynamodb) |
| **S3 (remote backend)** | Central, durable, **encrypted** state — works for teams, survives laptop loss |
| **DynamoDB (state lock)** | Prevents two `apply`s from corrupting state simultaneously |
| **AWS Secrets Manager** | Stores the SSH private key securely; supports rotation & IAM-scoped access |
| **IAM (roles/identity)** | Terraform & Ansible authenticate via IAM — **no static keys in code** |
| **Ansible** | Agentless configuration management — configure/update all servers in one run |
| **Ansible Roles** | Idiomatic, reusable structure (tasks / handlers / defaults / templates) |
| **EC2 / S3 / DynamoDB** | The actual application infrastructure being provisioned per environment |

---

## Project Structure

```
multi-environment-automation/
├── backends/
│   └── remote-backends.tf      # ONE-TIME: creates the S3 state bucket + DynamoDB lock table
├── terraform.tf                # versions + S3 remote backend config
├── providers.tf                # AWS provider
├── variables.tf                # region, instance_type, AMI filters
├── main.tf                     # locals (per-env counts) + AMI lookup + SSH key→Secrets Manager + module calls
├── outputs.tf                  # IPs, bucket/table names, secret name
├── modules/
│   ├── ec2/                    # main.tf, variables.tf, outputs.tf
│   ├── s3/                     # main.tf, variables.tf, outputs.tf
│   └── dynamodb/               # main.tf, variables.tf, outputs.tf
└── ansible-for-devops/
    ├── ansible.cfg
    ├── generate_inventory.sh   # fetches SSH key from Secrets Manager + builds inventory
    ├── group_vars/all.yml      # connection vars (user, key path)
    ├── site.yml                # entry playbook → applies the webserver role
    └── roles/webserver/
        ├── tasks/main.yml
        ├── handlers/main.yml
        ├── defaults/main.yml
        └── templates/index.html.j2
```

---

## Prerequisites

```bash
terraform -v        # >= 1.5.0
aws --version       # AWS CLI v2, configured via `aws configure`
ansible --version
jq --version
```
- An AWS account with credentials configured (`aws configure`) — these provide the **IAM identity** both Terraform and Ansible use.

---

## How to Run (Step by Step)

### Step 1 — Bootstrap the remote backend (run ONCE)
Creates the S3 state bucket + DynamoDB lock table that the main project uses.
```bash
cd remote-backends
terraform init
terraform apply        # type: yes
cd ..
```

### Step 2 — Initialize the main project
```bash
terraform init         # configures the S3 backend + downloads providers
terraform validate
```

### Step 3 — Provision the `dev` environment
```bash
terraform workspace new dev
terraform plan         # expect: 2 EC2, 1 S3, 1 DynamoDB
terraform apply        # type: yes
terraform output
```

### Step 4 — Provision `prod` (same code, different size)
```bash
terraform workspace new prod
terraform apply        # 4 EC2, 2 S3, 2 DynamoDB
terraform workspace select dev   # switch back when done
```

### Step 5 — Configure servers with Ansible
```bash
cd ansible-for-devops
chmod +x generate_inventory.sh
./generate_inventory.sh          # pulls SSH key from Secrets Manager + builds inventory.ini
```
```bash
ansible all -m ping              # verify connectivity (expect "pong")
ansible-playbook site.yml        # install packages + deploy landing page on ALL servers
```

### Step 6 — Verify
```bash
terraform -chdir=.. output ec2_public_ips
curl http://<ec2_public_ip>      # or open in a browser to see the landing page
```

### Step 7 — Tear down (avoid charges)
```bash
# destroy each workspace you created
terraform workspace select dev  && terraform destroy
terraform workspace select prod && terraform destroy
# (optional) remove the backend last
cd backends && terraform destroy
```

---

## How Secrets Are Handled

- Terraform **generates** the SSH keypair in code (`tls_private_key`) — no key files in git.
- The **public** key is placed on the EC2 instances; the **private** key is stored in **AWS Secrets Manager**.
- `generate_inventory.sh` fetches the private key at runtime using the **AWS CLI**, authenticated by your **IAM identity** (no static keys hardcoded anywhere).
- The fetched `key.pem` is gitignored; Ansible uses it to connect.
- Terraform **state is encrypted at rest** in S3 (it can contain sensitive values).

> **Principle:** no secrets in git, identity-based auth (IAM) over static keys, encryption at rest.

---

## Key Concepts Demonstrated

- Infrastructure as Code (Terraform)
- Multi-environment management with **workspaces** + a config-driven counts map
- **Reusable module** design
- **Remote state + state locking** (S3 + DynamoDB)
- **Secrets management** (AWS Secrets Manager) with **no static credentials**
- Encryption at rest (state, EBS, S3)
- **Configuration management** with Ansible **roles** + Jinja2 templates

---

## Future Improvements

- **SSM Session Manager** — connect without SSH keys or open port 22
- **Automatic secret rotation** via Secrets Manager
- **CI/CD pipeline** (GitHub Actions with OIDC — no long-lived AWS keys)
- **Restrict security groups** (SSH to specific CIDRs, not `0.0.0.0/0`)
- Dynamic inventory via the `amazon.aws.aws_ec2` plugin

---

