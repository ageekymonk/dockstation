class profiles::confluence inherits profiles::base {

  $confluence_config = hiera_hash("confluence_config")

  create_resources('class', $confluence_config, {'javahome' => '/usr'})

  file { '/app_home/certs':
    path => '/app_home/certs',
    source => 'puppet:///certs',
    owner => 'confluence',
    group => 'confluence',
    recurse => true
  }

  file { '/app_home/logs':
    ensure => 'link',
    target => '/app_logs',
    force => true,
  }

  # If u are using docker_mode then confluence will be running under supervisord
  if (hiera('docker_mode',false))
  {
    Class['supervisord'] ->

    supervisord::program { 'confluence':
      command     => "/opt/confluence/atlassian-confluence-${confluence_config['::confluence']['version']}/bin/start-confluence.sh -fg",
      user        => "confluence",
      autostart   => false,
      startsecs   => 0,
      stdout_logfile => '/app_logs/atlassian-confluence.info',
      stderr_logfile => '/app_logs/atlassian-confluence.error',
      stdout_logfile_maxbytes => '10MB',
      environment => {
        'JAVA_HOME'   => '/usr',
        'CATALINA_HOME' => "/opt/confluence/atlassian-confluence-${confluence_config['::confluence']['version']}",
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
    exec { 'start_confluence':
      command => '/usr/bin/supervisorctl start confluence',
      onlyif  => ["/usr/bin/ps -p `/usr/bin/cat /var/run/supervisord.pid`"],
      require => Class['::confluence']
    }
  }
}
