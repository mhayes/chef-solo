apt_repository "mongodb-10gen" do
  keyserver "keyserver.ubuntu.com"
  key "7F0CEB10"
  uri "http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen"
end

execute "apt-get update" do
  action :run
end

package "mongodb-10gen"