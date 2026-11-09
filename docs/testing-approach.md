# Testing approach (longer)

README has the short version. This is the fuller pass I would run.

## Offline

- `make fmt` / `make validate`
- Open `stacks/dev/main.tf` and check module inputs match variable names
- Search for live-looking secrets

## PR

- `tf-plan-dev` must go green (or explain fmt warnings)
- Read plan for destroys and open data paths
- Download artifact `tfplan-dev-<pr>` and keep `plan.txt` with the PR discussion

## Apply

- Only `workflow_dispatch` + confirm string `apply-dev` + Environment `dev-apply`
- Re-plan on main (do not apply a stale PR artifact blindly)
- Smoke: `/health`, ECS count, MySQL private, secret on task

## Stretch later

- tflint, Checkov
- OPA: deny public RDS
- Nightly drift plan
- Infracost comment on PRs for Dev sizing

## What I am not claiming

- Live apply against Jobbser accounts
- Import of existing Prod
- Mobile e2e tests
