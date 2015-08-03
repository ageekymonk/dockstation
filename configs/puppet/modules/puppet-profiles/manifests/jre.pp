class profiles::jre {

  $java_config = hiera_hash("java_config")

  class { 'java':
    distribution => $java_config['distribution'],
    package => $java_config['package']
  }

  if ($java_config['privileged']) {
    exec { 'set_java_permissions':
      command => "/usr/sbin/setcap 'cap_net_bind_service=+ep' /usr/java/${java_config['package']}/bin/java",
      require => Class['java']
    }
    ->
    file {'/etc/ld.so.conf.d/java.conf':
      content => "/usr/java/${java_config['package']}/lib/amd64/jli"
    }
    ->
    exec { 'refresh_ldconfig':
      command => "/usr/sbin/ldconfig"
    }
  }
}
