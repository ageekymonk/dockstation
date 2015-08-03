class profiles::db::postgresql {

  $postgresql_config = hiera('postgresql_config')

  class { 'postgresql::globals':
    version => $postgresql_config['version'],
    datadir => $postgresql_config['datadir'],
    logdir => $postgresql_config['logdir'],
    needs_initdb => true
  } ->
  class { 'postgresql::server':
    ip_mask_deny_postgres_user => '0.0.0.0/32',
    ip_mask_allow_all_users => '0.0.0.0/0',
    listen_addresses => '*',
    ipv4acls         => ['host all  all    0.0.0.0/0  md5'],
    service_manage => false,
    service_ensure => 'stopped',
  }
  ->
  file { 'postgres_logs_dir':
    path => $postgresql_config['logdir'],
    owner => 'postgres',
    group => 'postgres',
    ensure => "directory"
  }

  # If u are using docker_mode then postgresql will be running under supervisord
  if (hiera('docker_mode',false))
  {

    supervisord::program { 'postgresql':
      command     => "/usr/pgsql-${postgresql_config['version']}/bin/postgres -D ${postgresql_config['datadir']}",
      user        => 'postgres',
      autostart   => false,
      priority    => '100',
      environment => {
      }
    }

    exec { 'start_supervisord':
      command => '/usr/bin/supervisord -c /etc/supervisord.conf & sleep 5',
      unless  => ["/usr/bin/ps -p `/usr/bin/cat /var/run/supervisord.pid`"],
      require => Class['postgresql::server']
    }
    ->
    exec { 'start_postgresql':
      command => '/usr/bin/supervisorctl start postgresql && sleep 5',
      require => [Class['postgresql::server'], Exec['start_supervisord'] ]
    }
    ->
    supervisord::program { 'puppet':
      command     => "/usr/bin/puppet apply /etc/puppet/manifests/site.pp --certname=${::clientcert}",
      autostart   => true,
      priority    => '100',
      environment => {
      }
    }

    create_resources(postgresql::server::role, $postgresql_config['role'], {'require' => Exec['start_postgresql']})

    create_resources(postgresql::server::database, $postgresql_config['database'], {'require' => Exec['start_postgresql']})

    exec { 'set_postgres_password':
      command => "/usr/bin/psql -c \"alter role postgres password \'${postgresql_config['postgres_password']}\'\"",
      user => 'postgres',
      require => Exec['start_postgresql']
    }
  }
  else
  {
    create_resources(postgresql::server::role, $postgresql_config['role'])

    create_resources(postgresql::server::database, $postgresql_config['database'])

  }


}
