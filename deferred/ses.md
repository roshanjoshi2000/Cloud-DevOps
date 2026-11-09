# SES (not in this slice)

Inventory uses SES for verification / account / notification email.

I left it out of Terraform for now because:

1. Domain verification and DNS usually need a human who owns the domain.
2. The API path (ALB → ECS → MySQL → uploads → secret) is enough to prove the
   repo + Actions story.
3. Adding a half-baked `aws_ses_domain_identity` without knowing the domain feels
   like fake completeness.

When we do it: small module, identity ARN, attach `ses:SendEmail` to the
Jobbser-Api task role. Bounce/complaint handling can be a follow-up.
