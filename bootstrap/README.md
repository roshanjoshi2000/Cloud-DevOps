# Bootstrap remote state

One-shot root for the S3 state bucket and DynamoDB lock table (per account or
shared tooling account). Local state is fine for this root.

Typical flow:

1. `terraform.tfvars.example` → `terraform.tfvars`
2. `terraform init && terraform apply`
3. Bucket / table names go into `stacks/*/backend.hcl`

Stacks intentionally do not create their own backend. That avoids the
chicken-and-egg.
