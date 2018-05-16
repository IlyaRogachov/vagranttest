#!/bin/bash
echo 192.168.56.62 hello-world.com kibana.hello-world.com jenkins.hello-world.com >> /etc/hosts
vagrant up
sleep 2m
ssh -i /home/rogachev/.ssh/keys/virtualbox/server_ca vagrant@192.168.56.44 << EOF
sudo /opt/puppetlabs/bin/puppet cert sign --all
sudo puppet module install rtyler/jenkins
sudo puppet module install rehan-nginx
EOF
