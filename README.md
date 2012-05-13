What's Included
===============

  1. Nginx
  2. MySQL
  3. Unicorn (+ init script)
  4. Capistrano deploy.rb ready to use

Setup
=====

NOTE: We'll assume you're creating an application called `awesomeapp` on the `awesomeapp.com` for this README, adjust accordingly.

  1. Launch a new server (only Ubuntu 10.04 LTS has been tested)
  2. Run `curl https://raw.github.com/gist/b398348e220b4e3ca000/bootstrap.sh | sh`
  3. Run `ssh root@awesomeapp.com`
  4. Copy the chef cookbook to the server using `rsync -r . root@awesomeapp.com:chef`
  5. Copy `~/chef/node.json.sample` to `~/chef/node.json` and make any changes needed
  6. Run `chef-solo -c ~/chef/solo.rb`

Results
=======

Let's assume you create a new rails application with these defaults:

``` json
{
  "user": {
    "name":"deployer",
    "authorized_keys_url":"https://raw.github.com/gist/b398348e220b4e3ca000/public_keys.pub"
  },
  "mysql":{
    "server_root_password":"secret"
  },
  "rails_app":{
    "name":"awesomeapp",
    "database_password":"secret"
  },
  "run_list":["recipe[main]"]
}
```

  * The `deployer` user would be created and the public keys defined in `user => authorized_keys_url` would be able to login to the server.
  * `/var/www/awesomeapp` will be setup to store the Rails application.
  * `/var/www/awesomeapp/shared/config/database.yml` will be created.  The `awesomeapp_production` MySQL database will exist and it will be accessible by the `awesomeapp` user.
  * `/home/deployer/deploy/awesomeapp.rb` will be created.  This is a functional Capistrano `deploy.rb` file that can be copied down to the application folder.  It makes use of the `USR2` signal for zero-downtime deployments.
  * `/etc/init.d/unicorn_awesomeapp` will be created to automatically launch your Unicorn application on boot.  This will be run as the `deployer` user so that Capistrano script can reboot the script as necessary.

Other Instructions
==================

Simplify SSH Configuration
--------------------------

If you want to login to the server as the `deployer` user you could add the following to your `~/.ssh/config` file:

``` bash
Host awesomeapp
HostName awesomeapp.com
User deployer
```

Now you can run `ssh awesome` and it will do `ssh deployer@awesomeapp.com` in the background, neat-o!