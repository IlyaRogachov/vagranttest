#!/bin/bash
f=$(vboxmanage hostonlyif create | grep -Po 'vboxnet\d+')
vboxmanage hostonlyif ipconfig $f --ip 192.168.56.1

