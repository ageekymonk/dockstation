class profiles::base {

  $sudoers_config = hiera('sudoers',[])

  define set_sudoers_permission {
    sudo::conf { $name:
      priority => 10,
      content  => "${name} ALL=(ALL) NOPASSWD: ALL",
    }
  }

  if (size($sudoers_config) > 0) {

    class { 'sudo':
      config_file_replace => false,
    }

    set_sudoers_permission{$sudoers_config:}

  }

  $mandatory_packages = hiera('mandatory_packages', [])
  package { $mandatory_packages:
    ensure => latest
  }

}
