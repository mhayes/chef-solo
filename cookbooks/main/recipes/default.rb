package "git-core"
include_recipe "nginx"
include_recipe "mysql::server"
%w(mysql unicorn).each do |g|
  gem_package g do
    action :install
  end
end
include_recipe "mysql::client"

# Setup a Deployment User
user node[:user][:name] do
  home "/home/#{node[:user][:name]}"
  shell "/bin/bash"
  supports manage_home:true
end

directory "/home/#{node[:user][:name]}/.ssh" do
  mode "0700"
  owner node[:user][:name]
  group node[:user][:name]
end

remote_file "/home/#{node[:user][:name]}/.ssh/authorized_keys" do
  source node[:user][:authorized_keys_url]
  mode "0644"
  owner node[:user][:name]
  group node[:user][:name]
end

# Setup MySQL Database for Application
mysql_connection_info = {:host => "localhost", :username => "root", :password => node[:mysql][:server_root_password]}

mysql_database node[:rails_app][:database_name] do
  connection mysql_connection_info
  action :create
end

mysql_database_user node[:rails_app][:database_user] do
  connection mysql_connection_info
  password node[:rails_app][:database_password]
  database_name node[:rails_app][:database_name]
  action :grant
end

# Setup Capistrano Directory Structure
directory node[:rails_app][:www_path] do
  owner "root"
  group "root"
end
  
directory node[:rails_app][:www_app_path] do
  owner node[:user][:name]
  group node[:user][:name]
end

['releases', 'shared', 'shared/system', 'shared/pids', 'shared/log', 'shared/config', 'shared/tmp'].each do |path|
  directory "#{node[:rails_app][:www_app_path]}/#{path}" do
    owner node[:user][:name]
    group node[:user][:name]
  end
end

# Setup Rails / Nginx / Unicorn Configuration
template "#{node[:rails_app][:www_app_path]}/shared/config/database.yml" do
  source "rails_app_database_yml.erb"
  owner node[:user][:name]
  group node[:user][:name]
  mode "0640"
end

template "#{node[:rails_app][:www_app_path]}/shared/config/unicorn.rb" do
  source "rails_app_unicorn.erb"
  owner node[:user][:name]
  group node[:user][:name]
  mode "0640"
end

nginx_config_path = "#{node[:rails_app][:www_app_path]}/shared/config/nginx.conf"
template nginx_config_path do
  source "rails_app_nginx_site.erb"
  owner node[:user][:name]
  group node[:user][:name]
  mode "0640"
end
link "/etc/nginx/sites-available/#{node[:rails_app][:name]}" do
  to nginx_config_path
end
nginx_site node[:rails_app][:name]

# Setup init script so unicorn will boot automatically upon reboot
template "/etc/init.d/unicorn_#{node[:rails_app][:name]}" do
  source "unicorn_init.erb"
  owner "root"
  group "root"
  mode "0755"
end
execute "update-rc.d unicorn_#{node[:rails_app][:name]} defaults" do
  user "root"
end

# Save some capistrano deployment files that can be copied
directory "/home/#{node[:user][:name]}/deploy"
template "/home/#{node[:user][:name]}/deploy/#{node[:rails_app][:name]}.rb" do
  source "capistrano_deploy.erb"
  owner node[:user][:name]
  group node[:user][:name]
end