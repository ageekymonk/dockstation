class roles::jira {
  include profiles::docker
  include profiles::base
  include profiles::jre
  include profiles::jira
}
