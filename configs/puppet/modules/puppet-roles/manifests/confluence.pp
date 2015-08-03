class roles::confluence {
  include profiles::docker
  include profiles::base
  include profiles::jre
  include profiles::confluence
}
