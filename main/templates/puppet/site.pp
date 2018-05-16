class nginx {
  package { 'nginx':
    ensure => latest
  }
  service { 'nginx':
    ensure => 'running',
    enable => true,
    require => Package['nginx']
  }
}

node default {}
   file {'/tmp/example-ip':                                            # resource type file and filename
      ensure  => present,                                               # make sure it exists
      mode    => '0644',                                                # file permissions
      content => "Here is my Public IP Address: ${ipaddress_eth0}.\n",  # note the ipaddress_eth0 fact
    }


node 'puppet.local'{

  file { '/etc/puppetlabs/code/modules/puppetfiles/':
    owner  => 'vagrant',
    group  => 'vagrant',
    ensure => 'directory',
  }

  file { '/etc/puppetlabs/code/modules/puppetfiles/files':
    owner  => 'vagrant',
    group  => 'vagrant',
    ensure => 'directory',
  }

  file {'/usr/bin/determip.sh':
    owner  => 'root',
    group  => 'root',
    ensure => present,
    mode => '0755',
    source => 'puppet:///modules/myfiles/determip.sh',
  }


  exec { 'add_to_hosts':
        command => '/usr/bin/determip.sh',
        user    => 'root',
    }

}

node 'jenkins.local' {   

 include jenkins
 
 jenkins::plugin { 'display-url-api': }
 jenkins::plugin { 'git-client': } 
 jenkins::plugin { 'token-macro': }
 jenkins::plugin { 'jackson2-api': }
 jenkins::plugin { 'github-api': }
 jenkins::plugin { 'plain-credentials': }
 jenkins::plugin { 'matrix-project': }
 jenkins::plugin { 'scm-api': }
 jenkins::plugin { 'workflow-step-api': }
 jenkins::plugin { 'script-security': }
 jenkins::plugin { 'workflow-api': }
 jenkins::plugin { 'mailer': }
 jenkins::plugin { 'ssh-credentials': }
 jenkins::plugin { 'apache-httpcomponents-client-4-api': }
 jenkins::plugin { 'junit': }
 jenkins::plugin { 'jsch': }
 jenkins::plugin { 'javadoc': }
 jenkins::plugin { 'maven-plugin': }
 jenkins::plugin { 'workflow-scm-step': }
 jenkins::plugin { 'structs': }
 jenkins::plugin { 'git': }
 jenkins::plugin { 'github': }

 file {'/var/lib/jenkins/hudson.tasks.Maven.xml':
    ensure => present,
    owner  => 'jenkins',
    group  => 'jenkins',
    source => 'puppet:///modules/myfiles/hudson.tasks.Maven.xml',
  }

 file { '/var/lib/jenkins/jobs/Build':
    owner  => 'jenkins',
    group  => 'jenkins',
    ensure => 'directory',
  }

  file { '/var/lib/jenkins/jobs/Build/builds':
    owner  => 'jenkins',
    group  => 'jenkins',
    ensure => 'directory',
  }
 
  file {'/var/lib/jenkins/jobs/Build/config.xml':
    owner  => 'jenkins',
    group  => 'jenkins',
    ensure => present,
    source => 'puppet:///modules/myfiles/config.xml',
  }

  file { '/var/lib/jenkins/jobs/Deploy':
    owner  => 'jenkins',
    group  => 'jenkins',
    ensure => 'directory',
  }

  file { '/home/vagrant/hostsfile/':
    owner  => 'vagrant',
    group  => 'vagrant',
    ensure => 'directory',
   }

 file {'/home/vagrant/hostsfile/hosts':
    owner => 'vagrant',
    group => 'vagrant',
    ensure => present,
    source => 'puppet:///modules/puppetfiles/hosts',
  }


  file { '/var/lib/jenkins/jobs/Deploy/builds':
    owner  => 'jenkins',
    group  => 'jenkins',
    ensure => 'directory',
  }

  file {'/var/lib/jenkins/jobs/Deploy/config.xml':
    owner  => 'jenkins',
    group  => 'jenkins',
    ensure => present,
    source => 'puppet:///modules/myfiles/configdeploy.xml',
  }

  file {'/var/lib/jenkins/.ssh/server_ca':
    owner  => 'jenkins',
    group  => 'jenkins',
    ensure => present,
    source => 'puppet:///modules/myfiles/server_ca',
    mode => '0600',
   }


#  exec { 'auth_jenkins':
#    command => '/usr/bin/wget http://127.0.0.1:8080/jnlpJars/jenkins-cli.jar',
#    cwd => "/home/vagrant",
#  }


#  exec { 'authorize_jenkins':
#      command => 'cd /home/vagrant && pass=`sudo cat /var/lib/jenkins/secrets/master.key` && echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount("admin", "admin")' | sudo java -jar jenkins-cli.jar -auth admin:$pass -s http://localhost:8080/ groovy =',
#    }


  service { 'jenkins.service':
    ensure  => 'running',
    subscribe  => File["/var/lib/jenkins/jobs/Build/config.xml"],
  }
}

node /node\d+/ {    # applies to ns1 and ns2 nodes

   include apt

   apt::ppa { 'ppa:openjdk-r/ppa': 
       ensure => present,
   }

  file {'/etc/apt/sources.list.d/elastic-6.x.list':
    owner => 'root',
    group => 'root',
    ensure => present,
    source => 'puppet:///modules/myfiles/elastic-6.x.list',
  }
  
  exec { 'wget_key':
    command => '/usr/bin/wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -',
    cwd => "/tmp",
  }

   exec { 'apt-update':
      command => '/usr/bin/apt-get update && /usr/bin/apt-get install filebeat',
      require => [
        Apt::Ppa['ppa:openjdk-r/ppa']
       ],
    }

      package { 'openjdk-8-jdk':
        require  => [
          Exec['apt-update'],
          Apt::Ppa['ppa:openjdk-r/ppa'],
        ],
      }

  file {'/etc/filebeat/filebeat.yml':
    owner => 'root',
    group => 'root',
    ensure => present,
    source => 'puppet:///modules/myfiles/filebeat.yml',
  }



  exec { 'reload_elastic':
    command => '/bin/systemctl restart filebeat',
    subscribe  => File["/etc/filebeat/filebeat.yml"],
  }


  file {'/home/vagrant/runs.sh':
    owner => 'vagrant',
    group => 'vagrant',
    ensure => present,
    source => 'puppet:///modules/myfiles/runs.sh',
  }


  file { '/home/vagrant/hostsfile/':
    owner  => 'vagrant',
    group  => 'vagrant',
    ensure => 'directory',
   }


 file {'/home/vagrant/hostsfile/hosts':
    owner => 'vagrant',
    group => 'vagrant',
    ensure => present,
    source => 'puppet:///modules/puppetfiles/hosts',
  }
 
}

node 'nginx.local'{

 include nginx  

 file {'/etc/nginx/sites-enabled/hello.conf':
    owner => 'root',
    group => 'root',
    ensure => present,
    source => 'puppet:///modules/myfiles/hello.conf',
  }

 file {'/etc/nginx/sites-enabled/kibananginx.conf':
    owner => 'root',
    group => 'root',
    ensure => present,
    source => 'puppet:///modules/myfiles/kibana_nginx.conf',
  }


 file {'/etc/nginx/sites-enabled/jenkinsnginx.conf':
    owner => 'root',
    group => 'root',
    ensure => present,
    source => 'puppet:///modules/myfiles/jenkins_nginx.conf',
  }



 file {'/etc/nginx/conf.d/upstream.conf':
    owner => 'root',
    group => 'root',
    ensure => present,
    source => 'puppet:///modules/puppetfiles/upstream.conf',
  }
  
 exec { 'reload':
    command => '/bin/systemctl reload nginx',
    subscribe  => File["/etc/nginx/conf.d/upstream.conf"],
  }
 
}

node 'kibana.local'{

   include apt

   apt::ppa { 'ppa:openjdk-r/ppa':
       ensure => present,
   }
   exec { 'apt-update':
      command => '/usr/bin/apt-get update',
      require => [
        Apt::Ppa['ppa:openjdk-r/ppa']
       ],
    }

      package { 'openjdk-8-jdk':
        require  => [
          Exec['apt-update'],
          Apt::Ppa['ppa:openjdk-r/ppa'],
        ],
      }

  file {'/etc/apt/sources.list.d/elastic-6.x.list':
    owner => 'root',
    group => 'root',
    ensure => present,
    source => 'puppet:///modules/myfiles/elastic-6.x.list',
  }

  exec { 'apt-get-update':
      command => '/usr/bin/apt-get update',
      require => [
        Apt::Ppa['ppa:openjdk-r/ppa']
       ],
    }

  exec { 'wget_key':
    command => '/usr/bin/wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -',
    cwd => "/tmp",
  }

  exec { 'install-logstash':
      command => '/usr/bin/apt-get install logstash',
      require => [
        Apt::Ppa['ppa:openjdk-r/ppa']
       ],
    }

  exec { 'install-elastic':
      command => '/usr/bin/apt-get install elasticsearch',
      require => [
        Apt::Ppa['ppa:openjdk-r/ppa']
       ],
    }

 exec { 'install-kibana':
      command => '/usr/bin/apt-get install kibana',
      require => [
        Apt::Ppa['ppa:openjdk-r/ppa']
       ],
    }

  file { '/home/elasticsearch_data/':
    owner  => 'elasticsearch',
    group  => 'elasticsearch',
    ensure => 'directory',
   }

  file {'/etc/elasticsearch/elasticsearch.yml':
    owner => 'elasticsearch',
    group => 'root',
    ensure => present,
    source => 'puppet:///modules/myfiles/elasticsearch.yml',
  }
   
  file {'/etc/logstash/conf.d/logstash.conf':
    owner => 'root',
    group => 'root',
    ensure => present,
    source => 'puppet:///modules/myfiles/logstash.conf',
  }
 
#  exec { 'startlogstash_to_saveLA':
#    command => '/bin/systemctl start logstash',
#  }

 file {'/etc/kibana/kibana.yml':
    owner => 'root',
    group => 'root',
    ensure => present,
    source => 'puppet:///modules/myfiles/kibana.yml',
  }

  file { '/var/log/kibana/':
    owner  => 'kibana',
    group  => 'kibana',
    ensure => 'directory',
   }

  file {'/var/log/kibana/kibana.stdout':
    owner => 'kibana',
    group => 'kibana',
    ensure => present,
  }

  exec { 'reload_logstash':
    command => '/bin/systemctl restart logstash',
    subscribe  => File["/etc/logstash/conf.d/logstash.conf"],
    refreshonly => true,
  }
 
  exec { 'reload_kibana':
    command => '/bin/systemctl restart kibana',
    subscribe  => File["/etc/kibana/kibana.yml"],
    refreshonly => true,
  }

 exec { 'reload_elastic':
    command => '/bin/systemctl restart elasticsearch',
    subscribe  => File["/etc/elasticsearch/elasticsearch.yml"],
    refreshonly => true,
  }

}
