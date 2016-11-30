#
# Cookbook Name:: create
# Recipe:: default
#
# Copyright (C) 2016 Dilip Panwar
#
# All rights reserved - Do Not Redistribute
#
log "bc_setup::rvm setup started started"
release_version = node['release_version']
app_path = "#{node['bc_setup']['app_home']}/#{node['release_version']}"
pkg_name = "devops-test_#{release_version}_amd64.deb"
artifactory_user = 'admin'
artifactory_password = 'admin123'
#http://35.162.127.170:8082/nexus/service/local/repositories/myrepo/content/devops-test_0.1.0_amd64.deb
artifactory_url = '35.162.127.170:8082/nexus/service/local/repositories/myrepo/content'

log "app path is #{app_path}"
directory "#{app_path}" do
  owner 'ubuntu'
  group 'ubuntu'
  mode '2755'
  recursive true
end

remote_file "Downloading app from Nexus" do
  source "http://#{artifactory_user}:#{artifactory_password}@#{artifactory_url}/devops-test_#{release_version}_amd64.deb"
  owner 'ubuntu'
  group 'ubuntu'
  mode '2755'
  path "#{app_path}/devops-test_#{release_version}_amd64.deb"
  action :create
end

dpkg_package pkg_name do
  source "#{app_path}/#{pkg_name}"
  action :purge
  ignore_failure true
end

package pkg_name do
  #source "#{app_path}/#{pkg_name}"
  action :nothing
  ignore_failure true
end

dpkg_package pkg_name do
  source "#{app_path}/#{pkg_name}"
  action :install
end

chef_rvm 'ubuntu' do
  rubies ['2.3.0', '2.3.1']
  rvmrc({
    'rvm_autoupdate_flag'=> '1'
  })
end
chef_rvm_gemset 'ubuntu:gemset:2.3.0:sinatra' do
   ruby_string '2.3.0@sinatra'
   user 'ubuntu'
   action :create
end
chef_rvm_gem 'ubuntu:rack-test' do
   gem 'rack-test'
   user 'ubuntu'
   ruby_string '2.3.0@sinatra'
end

chef_rvm_gem 'ubuntu:simplecov' do
   gem 'simplecov'
   user 'ubuntu'
   ruby_string '2.3.0@sinatra'
end
chef_rvm_gem 'ubuntu:simplecov-rcov' do
   gem 'simplecov-rcov'
   user 'ubuntu'
   ruby_string '2.3.0@sinatra'
end
chef_rvm_gem 'ubuntu:rspec' do
   gem 'rspec'
   user 'ubuntu'
   ruby_string '2.3.0@sinatra'
end

chef_rvm_script 'bundle_install_sh' do
  interpreter 'sh'
  ruby_string '2.3.0@sinatra'
  user 'ubuntu'
  cwd "#{app_path}/devops-test"
  code <<CODE
      bundle install
      rackup config.ru --port 9292 -o 0.0.0.0 -D
CODE
  action :run
end

link '/apps/bc-app/releases/current' do
  to app_path
  owner 'ubuntu'
  group 'ubuntu'
  mode '2755'
end
log "bc_setup::Application setup done... "
