class roles::jiradb {
  include profiles::docker
  include profiles::base
  include profiles::db::postgresql
}
