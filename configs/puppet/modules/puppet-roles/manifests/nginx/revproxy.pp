class roles::nginx::revproxy {
  include profiles::docker
  include profiles::base
  include profiles::nginx::revproxy
}
