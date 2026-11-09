# OIDC notes (placeholders)

Two roles. Plan is weaker. Apply is stronger but gated by Environment `dev-apply`
and a confirm string in the workflow.

Trust sketch for plan:

```json
{
  "Effect": "Allow",
  "Principal": {
    "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
  },
  "Action": "sts:AssumeRoleWithWebIdentity",
  "Condition": {
    "StringEquals": {
      "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
    },
    "StringLike": {
              "token.actions.githubusercontent.com:sub": "repo:OWNER/REPO:*"
    }
  }
}
```

For apply I would tighten `sub` to the main branch (and ideally this workflow
name) so a random PR cannot assume the apply role even if someone edits YAML.
