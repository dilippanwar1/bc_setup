release_version = node['release_version']
app_path = "#{node['bc_setup']['app_home']}/#{node['release_version']}"

cookbook_file '/apps/bc-app/releases/0.1.1/devops-test/bin/start.sh' do
  source 'start.sh'
  mode '0755'
  owner 'ubuntu'
  group 'ubuntu'
end

cookbook_file '/etc/init/bc-app.conf' do
  source 'bc-app.conf'
  mode '0755'
  owner 'ubuntu'
  group 'ubuntu'
end

execute "Starting service for deployed app version #{release_version}" do
  user 'ubuntu'
  cwd "#{app_path}/devops-test/bin"
  command "bash -x start.sh"
  live_stream true
  action :nothing
end

service "bc-app" do
  supports :status => true, :restart => true
  start_command "bc-app.conf"
  restart_command "#{app_path}/devops-test/bin/start.sh"
  status_command "#{app_path}/devops-test/bin/start.sh"
  action :start
end

execute "Starting service for deployed app version #{release_version}" do
  user 'ubuntu'
  cwd "#{app_path}/devops-test"
  command ' rvm use 2.3.0 && rvm gemset use sinatra230 && rackup config.ru --port 9292 -o 0.0.0.0 &'
  live_stream true
  action :nothing
end


