class roles::postgresql {
  include profiles::docker
  include profiles::base
  include profiles::db::postgresql
}
