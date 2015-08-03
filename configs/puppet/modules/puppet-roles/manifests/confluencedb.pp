class roles::confluencedb {
  include profiles::docker
  include profiles::base
  include profiles::db::postgresql
}
