#!/bin/bash
apt-get update
apt-get install -y ansible
rm -rf /tmp/ansible
mkdir -p /tmp/ansible