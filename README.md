# puppet-owncloud

originally modified from<br>
 LeonB/puppet-owncloud  [https://github.com/LeonB/puppet-owncloud/blob/master/manifests/server/package.pp ]

Feel free to pull and improve or contribute. My own understanding of puppet is minimal.

This puppet module is to deploy owncloud in fedora or fedora-like distributions.  I had trouble with other puppet deployments because paths and otherthings can be different. Also many are based on the nginx web-server

*note*: 
It is very painful to get apache to work well with php-fpm, that's perhaps one of the main reasons for sysadms to prefer nginx, the high performance of the simpler nginx being the other considerations. Why apache? because its usually already there and configured.  php-fpm seems to be the prefered way inheritted from nginx 

Made to work with
* Fedora-20
* php-fpm-5.5.9-1.fc20.x86_64
* owncloud-5.0.14a-2.fc20.noarch
* httpd-2.4.6-6.fc20.x86_64
* mariadb-server-5.5.35-3.fc20.x86_64

Other relavant puppet modules
* ├── puppetlabs-apache (v0.8.1)
* ├── puppetlabs-mysql (v2.1.0)
* ├── thias-php (v0.3.8)


## SRF
* to work with apache server
* to work with php-fpm
* to have a separate owncloud server that worked on a fedora based system
* will create the user owncloud
* will itself configure/create the mysql database 'owncloud' accesible via a mysql-user owncloud
* will itself configure the apache vhost and have it run as user 'owncloud' on port 8080
* will itself configure the mysql database with user access owncloud
* will itself configure the php-fpm to run as user 'owncloud' on port 9006
* will change ownership permission on relavant directories

## Directories
* /etc/owncloud is where fedora puts owncloud configuration files by default  
* /usr/share/owncloud is the rpm installs, need to be owncloud readable
* /var/lib/owncloud is the owncloud root directory 
* /var/lib/owncloud/data is the owncloud data directory
* /var/lib/owncloud/data.log /var/lib/httpd , /var/lib/php-fpm are log directories

## Invitation for improvements
Troubles that need ironing out, handled manually as of creation of this git-repo.
* there is trouble between owncloud-4 and owncloud-5
* the config hash sometimes does not match with a pre-existing owncloud database
* some file directory permissioning
* owncloud upgrades tend to rewrite the /etc/owncloud directory and change permissions
* owncloud files need to be owned by user 'owncloud'
* maybe something needs to be done about the owncloud local apps directory /var/lib/owncloud/apps
* Some things need to be parametrized out, like fpm port, whether owncloud should be hosted at the url root folder or under a subdirectory/sublocation/subdomains.
* harmonize/parametrize nginx/apache configuration
* harmonize/parametrize rpm/deb systems

## Configuration
Include in manifest the following
```
class { 'owncloud::server':
  mysql_password => 'changeme',
}
```

Other customization or param modification can be made in  
```
manifest/server/params.pp
manifest/server/config.pp
templates/apache_vhost/subdirectory.erb
```

