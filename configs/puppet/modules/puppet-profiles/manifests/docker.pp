class profiles::docker {

#  if (hiera('docker_mode',false))
#  {
#    class { 'supervisord':
#      nodaemon => true,
#      service_ensure => 'stopped',
#      install_pip => true,
#    }
#  }

}
