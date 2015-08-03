FROM ubuntu:latest
MAINTAINER Ramz <ramzthecoder@gmail.com>

WORKDIR /tmp

# Update the repos
RUN apt-get update -y
RUN apt-get install -y wget

# Install puppet
RUN wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
RUN dpkg -i puppetlabs-release-trusty.deb
RUN apt-get update -y
RUN apt-get install -y puppet

# Install r10k
RUN gem install minitar r10k

# Add the configs
ADD configs/puppet /etc/puppet
ADD configs/hiera /etc/puppet/hieradata
RUN cd /etc/puppet/ && r10k puppetfile install
ADD configs/puppet/modules/puppet-roles /etc/puppet/modules/roles
ADD configs/puppet/modules/puppet-profiles /etc/puppet/modules/profiles

# Run puppet apply
ENV FACTER_role roles::postgresql
RUN puppet apply /etc/puppet/manifests/site.pp --certname dbserver
