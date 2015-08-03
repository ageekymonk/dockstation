class profiles::jira inherits profiles::base {

  $jira_config = hiera_hash("jira_config")

  file { '/app_home/certs':
    path => '/app_home/certs',
    source => 'puppet:///certs',
    owner => 'jira',
    group => 'jira',
    recurse => true
  }

  file { '/app_home/configs':
    path => '/app_home/configs',
    source => 'puppet:///configs',
    owner => 'jira',
    group => 'jira',
    recurse => true
  }

  create_resources('class', $jira_config, {'javahome' => '/usr', 'service_ensure' => 'stopped'})

  # If u are using docker_mode then jira will be running under supervisord
  if (hiera('docker_mode',false))
  {
    Class['supervisord'] ->

    supervisord::program { 'jira':
      command     => "/opt/jira/atlassian-jira-${jira_config['::jira']['version']}-standalone/bin/start-jira.sh -fg",
      user        => "jira",
      autostart   => false,
      startsecs   => 0,
      stdout_logfile => '/app_logs/atlassian-jira.log',
      stderr_logfile => '/app_logs/atlassian-jira.error',
      stdout_logfile_maxbytes => '10MB',
      environment => {
        'JAVA_HOME'   => '/usr',
        'CATALINA_HOME' => "/opt/jira/atlassian-jira-${jira_config['::jira']['version']}-standalone",
      }
    }
    ->
    supervisord::program { 'puppet':
      command     => "/usr/bin/puppet apply /etc/puppet/manifests/site.pp --certname=${::clientcert}",
      autostart   => true,
      priority    => '100',
      environment => {
      }
    }
    ->
    exec { 'start_jira':
      command => '/usr/bin/supervisorctl start jira',
      onlyif  => ["/usr/bin/ps -p `/usr/bin/cat /var/run/supervisord.pid`"],
      require => Class['::jira']
    }
  }

}
