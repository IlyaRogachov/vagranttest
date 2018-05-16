#!/bin/bash
vagrant up
sleep 1m
cd ./own && ansible-playbook -i inventory.cfg playbook/ownrun.yaml
sleep 3m
cd ../kargo && ansible-playbook -i inventory/inventory.cfg cluster.yml
sleep 1m
cd ../dockerrepo && ansible-playbook -i inventory.cfg playbook/ownrun.yaml
sleep 1m
cd ../jenkinsans && ansible-playbook -i inventory.cfg  playbook/newown.yaml
