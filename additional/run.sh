#!/bin/bash
echo 192.168.56.82 kuber.hello-world.com >> /etc/hosts
vagrant up
sleep 1m
cd ./own && ansible-playbook -i inventory.cfg playbook/ownrun.yaml
sleep 3m
cd ../kargo_bk && ansible-playbook -i inventory/inventory.cfg cluster.yml
sleep 1m
cd ../dockerrepo && ansible-playbook -i inventory.cfg playbook/ownrun.yaml
sleep 1m
cd ../jenkinsans && ansible-playbook -i inventory.cfg  playbook/newown.yaml
