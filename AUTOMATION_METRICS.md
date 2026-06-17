# Automation vs Manual — Time Metrics Log

Tracks the time cost of running this project with automation (Terraform + Ansible)
versus doing the equivalent work by hand (AWS Console + manual SSH).

## Metric definitions
- **Automation wall-clock**: measured command runtime (hands-off).
- **Manual estimate**: time to reproduce the same resources/config via AWS Console + SSH.
- **Hands-on saved**: human attention time saved (type-and-walk-away vs clicking).
- **Speedup**: manual ÷ automation.

---

## Run 1 — 2026-06-17 — `dev` workspace (initial provision + configure)

**Provisioned:** 12 resources — TLS keypair, AWS key pair, Secrets Manager secret+version,
2× EC2 t3.micro (10GB gp3 encrypted), security group (80/22), default VPC,
S3 bucket (versioning + AES256), DynamoDB table.
**Configured:** 2 hosts — nginx landing page deploy + restart (Ansible `webserver` role).

| Step | Command | Measured |
|------|---------|----------|
| Init | `terraform init` | ~5 s (cached) |
| Validate | `terraform validate` | ~1 s |
| Plan | `terraform plan` | ~8 s |
| Apply | `terraform apply` | ~30 s (EC2 14s ∥ DDB 9s ∥ S3 6s) |
| Inventory | `generate_inventory.sh` | ~4 s |
| Configure | `ansible-playbook ui.yml` | ~20 s |
| **Total automation** | | **≈ 68 s** |

| Metric | Manual | Automation | Result |
|--------|--------|-----------|--------|
| Wall-clock (dev) | ~43 min | ~1.1 min | **~97% faster (≈39×)** |
| Hands-on saved | — | — | **~42 min** |
| prod projection (4 EC2 / 2 S3 / 2 DDB) | ~65–90 min | ~1.5 min | **~50×** |

**Notes:** automation wall-clock stays ~flat as environment scales (dev→prod = one
`terraform workspace select`); manual time grows linearly with resource count.

---

<!-- Append future runs below this line, same format. -->
