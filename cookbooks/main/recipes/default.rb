package "git-core"
include_recipe "nginx"
include_recipe "mongo"

mongo_user node[:rails_app][:database_name] do
  user node[:rails_app][:database_username]
  password node[:rails_app][:database_password]
end

# Setup a Deployment User
user node[:user][:name] do
  home "/home/#{node[:user][:name]}"
  shell "/bin/bash"
  supports manage_home:true
end

execute "sudo usermod -a -G admin #{node[:user][:name]}"

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
template "#{node[:rails_app][:www_app_path]}/shared/config/mongoid.yml" do
  source "rails_app.mongoid.yml.erb"
  owner node[:user][:name]
  group node[:user][:name]
  mode "0640"
end

template "#{node[:rails_app][:www_app_path]}/shared/config/unicorn.rb" do
  source "rails_app.unicorn.rb.erb"
  owner node[:user][:name]
  group node[:user][:name]
  mode "0640"
end

nginx_config_path = "#{node[:rails_app][:www_app_path]}/shared/config/nginx.conf"
template nginx_config_path do
  source "rails_app.nginx_site.conf.erb"
  owner node[:user][:name]
  group node[:user][:name]
  mode "0640"
end
link "/etc/nginx/sites-available/#{node[:rails_app][:name]}" do
  to nginx_config_path
end
nginx_site node[:rails_app][:name]

execute "start-unicorn" do
  command "start unicorn_#{node[:rails_app][:name]}" 
  user "root"
  action :nothing
end

# Setup init script so unicorn will boot automatically upon reboot
template "/etc/init/unicorn_#{node[:rails_app][:name]}.conf" do
  source "rails_app.unicorn_init.conf.erb"
  owner "root"
  group "root"
  mode "0755"
  notifies :run, resources(:execute => "start-unicorn"), :immediately
end

# Save some capistrano deployment files that can be copied
directory "/home/#{node[:user][:name]}/deploy"
template "/home/#{node[:user][:name]}/deploy/#{node[:rails_app][:name]}.rb" do
  source "rails_app.deploy.rb.erb"
  owner node[:user][:name]
  group node[:user][:name]
end

# Make sure unicorn gem is present
gem_package "unicorn"