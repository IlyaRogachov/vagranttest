#!/bin/bash
rm -rf /etc/puppetlabs/code/modules/myfiles/files/hosts
rm -rf /home/vagrant/hosts
cp /etc/hosts /home/vagrant/
sed -n -i '1,8p' /home/vagrant/hosts
/opt/puppetlabs/bin/puppet cert list --all |awk {'print $2'} | tr -d \" > /tmp/two
/opt/puppetlabs/bin/puppet cert list --all |awk {'print $2'} |grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" > /tmp/one
paste --delimiters=' ' /tmp/one /tmp/two >> /home/vagrant/hosts
sed -i '$ d' /home/vagrant/hosts
cp /home/vagrant/hosts /etc/puppetlabs/code/modules/puppetfiles/files/hosts
rm -rf /etc/puppetlabs/code/modules/puppetfiles/files/upstream.conf
echo  'upstream backend {' >> /etc/puppetlabs/code/modules/puppetfiles/files/upstream.conf
for i in $(cat /etc/puppetlabs/code/modules/puppetfiles/files/hosts |grep node[[:digit:]] |awk {'print $1'}); do echo server $i:8080 max_fails=0\; >> /etc/puppetlabs/code/modules/puppetfiles/files/upstream.conf; done
echo '}'  >> /etc/puppetlabs/code/modules/puppetfiles/files/upstream.conf
