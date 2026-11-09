# JobbserMsgHub (not in this slice)

Inventory has a separate realtime hub service next to Jobbser-Api.

I would copy the `jobbser-api` module pattern (or parameterize it) and add a
second listener rule on the same ALB. Own task definition, own log group, own
desired count.

Why wait: first make Dev API cheap and parkable. Then hub. Two always-on
services in Dev recreates the cost problem the inventory already calls out.
