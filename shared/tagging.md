# Tagging contract

I settled names and tags before touching VPC/ECS. The inventory does not spell
a scheme out, so this is what I used.

## Names

Pattern: `jb-<env>-<thing>`

Dev examples:

- `jb-dev-vpc`
- `jb-dev-alb`
- `jb-dev-api` (ECS service / task family, close to inventory `jobbser-prd-api`)
- `jb-dev-mysql`
- `jb-dev-uploads`

Prefix is short on purpose. ALB names and some AWS limits are tight.

## Required tags

Every resource gets these via provider `default_tags` plus module merges:

| Key | Example | Why |
| --- | --- | --- |
| `jb_project` | `jobbser` | filter in Cost Explorer |
| `jb_env` | `dev` / `check` / later `prod` | Dev being always-on hurt; need a clean split |
| `jb_component` | `api` / `mysql` / `uploads` / `edge` | blame a line item |
| `managed_by` | `terraform` | know what is in this repo |
| `billed_to` | `roshan` (or team) | who answers when Dev burns money overnight |

Optional later: `jb_service=jobbser-api` vs `jobbsermsghub` when MsgHub lands.

## What I am not doing yet

No org-level SCP. No enforced tag policy in AWS. Just consistency in this repo so a senior can add enforcement later without renaming everything.
