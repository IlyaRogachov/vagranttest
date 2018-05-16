class myfile {
    file { '/home/operator1/Desktop/Backup':
        ensure => directory,
        mode => '0755',
        owner => 'jenkins',
        group => 'jenkins',
    }

    file { "/var/lib/jenkins/hudson.tasks.Maven.xml":
        mode => "0644",
        owner => 'jenkins',
        group => 'jenkins',
        source => 'puppet:///modules/myfiles/hudson.tasks.Maven.xml',
    }
}
