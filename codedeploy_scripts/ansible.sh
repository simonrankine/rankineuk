#!/bin/bash
ansible-galaxy collection install community.general 
ansible-galaxy install christiangda.amazon_cloudwatch_agent
ansible-playbook /tmp/ansible/playbook.yml