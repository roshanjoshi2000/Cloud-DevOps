# `check` stack (stretch)

I called this `check` instead of `test` so it is obvious in tags/Cost Explorer
and does not collide with "test" meaning unit tests.

Same modules as Dev. Separate state key. Own VPC CIDR. Own secret. Own MySQL.

I am not solving the data refresh problem here. That is basically Task 3.
This stack only shows the repo can grow a second env without copy-pasting
modules.
