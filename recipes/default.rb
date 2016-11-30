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
execute 'Configuring gpg key for RVM setup' do
  user 'ubuntu'
  cwd '/home/ubuntu'
  command 'gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3'
  action :run
end

execute 'Downloading and Installing RVM' do
  user 'ubuntu'
  cwd '/home/ubuntu'
  command "\\curl -L https://get.rvm.io | bash -s stable"
  action :run
end

execute 'loading rvm after installation' do
  user 'ubuntu'
  cwd '/home/ubuntu'
  command "./env.sh"
  action :nothing
end

log "app path is #{app_path}"
directory "#{app_path}" do
  owner 'ubuntu'
  group 'ubuntu'
  mode '2755'
  action :create
  recursive true
end

#remote_file "Downloading app from Nexus" do
#  source "http://#{artifactory_user}:#{artifactory_password}@#{artifactory_url}/devops-test-#{release_version}.tar"
#  owner 'ubuntu'
#  group 'ubuntu'
#  mode '2755'
#  path "#{app_path}/devops-test-#{release_version}.tar"
#  action :create
#end


remote_file "Downloading app from Nexus" do
  source "http://#{artifactory_user}:#{artifactory_password}@#{artifactory_url}/devops-test_#{release_version}_amd64.deb"
  owner 'ubuntu'
  group 'ubuntu'
  mode '2755'
  path "#{app_path}/devops-test_#{release_version}_amd64.deb"
  action :create
end

#execute "Exploding app version #{release_version} at #{app_path}" do
#  user 'ubuntu'
#  cwd "#{app_path}/"
#  command "tar -xvf devops-test-#{release_version}.tar"
#  action :run
#end

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

execute "Installing app version #{release_version}" do
  #user 'ubuntu'
  cwd "#{app_path}"
  command "sudo dpkg -i #{pkg_name}"
  #ignore_failure true
  action :nothing
end


execute "Setting up app version #{release_version}" do
  user 'ubuntu'
  cwd "#{app_path}/devops-test/bin"
  command "./env.sh"
  action :run
end

execute "Starting service for deployed app version #{release_version}" do
  user 'ubuntu'
  cwd "#{app_path}/devops-test/bin"
  command "./start.sh"
  live_stream true
  action :run
end

execute "Starting service for deployed app version #{release_version}" do
  user 'ubuntu'
  cwd "#{app_path}/devops-test"
  command ' rvm use 2.3.0 && rvm gemset use sinatra230 && rackup config.ru --port 9292 -o 0.0.0.0 &'
  live_stream true
  action :nothing
end
link '/apps/bc-app/releases/current' do
  to app_path
  owner 'ubuntu'
  group 'ubuntu'
  mode '2755'
end
log "bc_setup::rvm setup started ended "

