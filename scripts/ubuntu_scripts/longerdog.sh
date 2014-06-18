#!/bin/sh
# Change terminal title
echo -en "\033]0;SSH longerdog\a"
ssh joncrall@longerdog.com -i ~/.ssh/id_rsa
