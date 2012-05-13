Setup
=====

To keep a cookbook saved locally in sync with what's on production you can use rsync.

First let's create an SSH shortcut to save time:

Inside `~/.ssh/config` add the following entry:

``` bash
Host tweeshirt
HostName stage.tweeshirt.me
User root
```
Now when you're within the `chef directory` you can run the following:

`rsync -r . tweeshirt:chef`

This will keep `/root/chef` up to date.

Running Chef
============

chef-solo -c solo.rb