# Architecture notes

Greenfield. Matches Jobbser inventory shape. Does not claim to manage current Prod.

## Inventory → modules

| Inventory | In slice? | Where |
| --- | --- | --- |
| VPC / ALB | yes | `modules/vpc-alb` |
| Secrets Manager | yes | `modules/api-runtime-secret` |
| RDS MySQL | yes | `modules/jobbser-mysql` |
| ECS Jobbser-Api | yes | `modules/jobbser-api` (+ task SG in stack) |
| S3 uploads | yes | `modules/upload-bucket` |
| CloudWatch logs / IAM | yes | inside `jobbser-api` |
| SES | deferred | `deferred/ses.md` |
| JobbserMsgHub | deferred | `deferred/msghub.md` |
| ECR | assumed existing | `api_image_uri` input |

## Why SG is in the stack

```
edge → secret → api_tasks SG → mysql → jobbser-api → uploads
```

MySQL needs the API SG id. If that SG lived only inside the ECS module, MySQL
would depend on the service module. I flipped it so DB rules come first.

## Cost posture

NAT, public IPv4, Fargate, ALB dominate. Dev park flag + single NAT are the main
knobs. See README.

## Adoption path I would pitch

1. Bootstrap state  
2. Stand up `stacks/dev` for API smoke tests  
3. Add MsgHub / SES when DNS and product need them  
4. Talk about Prod import or rebuild only after Dev is boring
