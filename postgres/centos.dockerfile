FROM centos:7
MAINTAINER Ramz Sivagurunathan <ram.sivagurunathan@iag.com.au>

WORKDIR /tmp

# Update from the private repo
RUN yum update -y

# If there are multiple packages in single line yum does not send right error code if one fails
RUN yum install -y wget \
 && yum install -y git \
 && yum install -y openssl \
 && yum install -y curl \
 && yum install -y tar \
 && yum install -y hostname

# Install Puppet
RUN rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
RUN yum install -y puppet

RUN gem install minitar r10k
RUN pip install supervisor

RUN curl https://bootstrap.pypa.io/get-pip.py | python -

# Set the Timezone
RUN rm -Rf /etc/localtime
RUN ln -s /usr/share/zoneinfo/Australia/Sydney /etc/localtime


# Install all puppet modules

# Run puppet apply
RUN puppet apply /etc/puppet/manifests/site.pp --certname docker-centos
