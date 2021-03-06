# puppet-owncloud


Source Hosted on Github: Lesser Affero GPLv3 (AGPLv3 with library, linking, and combining exception). The intent is that you may use this with other commerical or non-open systems without fear. Significant fixes/feature improvements to this software/module that is of relavance to users be contributed back to community.

---------- 
Lesser AGPLv3  : Linking, combining exemption.

puppet-owncloud is free software, you can redistribute it and/or modify
it under the terms of GNU Affero General Public License
as published by the Free Software Foundation, either version 3
of the License, or (at your option) any later version.

You should have received a copy of the the GNU Affero
General Public License, along with puppet-owncloud. If not, see the file LICENSE.AGPLv3

Additional permission under the GNU Affero GPL version 3 section 7:

If you modify this Program, or any covered work, by linking or
combining it with other code, such other code is not for that reason
alone subject to any of the requirements of the GNU Affero GPL
version 3.

----------



 <br> hgkamath/puppet-owncloud  [https://github.com/hgkamath/puppet-owncloud ]
 <br> puppetforge: [https://forge.puppetlabs.com/hgkamath/owncloud]
 <br> modified source originally from: LeonB/puppet-owncloud

Feel free to pull and improve or contribute. My own understanding of puppet is minimal.

This puppet module is to deploy owncloud in fedora or fedora-like distributions.  I had trouble with other puppet deployments because paths and otherthings can be different. Also many are based on the nginx web-server

*note*: 
It is very difficult to get apache to work well with php-fpm, as there is development work going on in the redirection and proxy directives. nginx is another lightweight and high-speed web-server, whos primary deisgn is to reverse-proxy to other servers both to prevent feature creep, to push scripting into seprate servers like php-fpm and also to manage scalability. That's why there exists a preference for nginx, the high performance of the simpler nginx being the other consideration. The advantage of Apache is that it is ubiquitous, nothing new for anyone to learn and usually already installed and configured. Despite apache having modphp for fast scripting, the scalability that php-fpm offered is still desirable as owncloud was designed in order to be able to proxy and scale up. 

Made to work with
* Fedora-22
* puppet-4.1.0-1.fc22.x86_64
* httpd-2.4.16-1.fc22.x86_64
* mariadb-server-10.0.20-1.fc22.x86_64
* owncloud-8.0.5-1.fc22.noarch
* php-fpm-5.6.11-2.fc22.x86_64

Other relavant puppet modules
* ├── puppetlabs-apache (v1.6.0)
* ├── puppetlabs-mysql (v3.5.0)
* ├── thias-php (v1.1.1)

## Usable versions
* 0.2.2 : httpd-2.4.16-1, mariadb-server-10.0.20-1, owncloud-8.0.5-1   , php-fpm-5.6.11-2, puppet-4.1.0-1.fc22
* 0.2.1 : httpd-2.4.9-2 , mariadb-server-5.5.37-1 , owncloud-6.0.3-1   , php-fpm-5.5.13-3 
* 0.1.4 : httpd-2.4.6-6 , mariadb-server-5.5.35-3 , owncloud-5.0.14a-2 , php-fpm-5.5.9-1  

## desired software requirements and functionalities
* to work with apache server
* to work with php-fpm
* to have a separate owncloud server that worked on a fedora based system
* will create the user owncloud
* will itself configure/create the mysql database 'owncloud' accesible via a mysql-user owncloud
* will itself configure the apache vhost and have it run as user 'owncloud' on port 8080
* will itself configure the mysql database with user access owncloud
* will itself configure the php-fpm to run as user 'owncloud' on port 9006
* will change ownership permission on relavant directories

## File and Directories
* /etc/owncloud is where fedora puts owncloud configuration files by default. /usr/share/owncloud/config is a symbolic link to here.
* /usr/share/owncloud is the rpm installs, need to be owncloud readable
* /var/lib/owncloud is the owncloud root directory 
* /var/lib/owncloud/data is the owncloud data directory
* /var/lib/owncloud/data.log /var/lib/httpd , /var/lib/php-fpm are log directories
* creates an apache vhost in configuration file /etc/httpd/conf.d/25-owncloud.conf on port 8080

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
package { 'httpd':
  ensure => installed,
}
service { 'httpd':
  enable => true,
  ensure => running,
  require => Package['httpd']
}

apache::mod { 'access_compat': }
apache::mod { 'slotmem_shm': }
apache::mod { 'proxy': }
apache::mod { 'proxy_fcgi': }

apache::vhost { 'owncloud':
    ensure  => present,
    name => 'owncloud',
    docroot => '/var/www/html2',
    port => '8920',
    directories => [ {
        path => '/var/www/html2',
        auth_require => 'ip 127.0.0.1 ::1',
        options => ['ExecCGI', 'Includes', 'Indexes','FollowSymLinks','MultiViews'], 
      },
       $owncloud::server::config::apache_vhostdir,
       ],
    custom_fragment => join( [ template($owncloud::server::config::apache_custfrag_template),
        '
<Location /balancer-manager> 
    SetHandler balancer-manager 
    Order allow,deny
    Allow from 127.0.0.1 ::1
</Location> 
ProxyStatus On' , ] )
}


class { 
  '::mysql::server': 
  #old_root_password => '',
  root_password => 'changeme',
  service_enabled => true,
}

class { 'owncloud::server':
  mysql_password => 'changeme',
  passwordsalt => undef,
  instanceid => undef,
  # $path => '/usr/share/owncloud',
  # $data_dir => '/var/lib/owncloud',
  # $user           => 'owncloud',
  # $passwordsalt   => undef,
  # $mysql_database => 'owncloud',
  # $mysql_user     => 'owncloud',
  # $mysql_host     => 'localhost',
  # $apache_vhost   => false,         
}
```

* owncloud puppet module can make its own apache vhost if apache_vhost is set to true
* owncloud puppet module will make its own mysql database

### explanation of options
* path: root directory containing owncloud php files
* data_dir : root directory containing the data files that owncloud manages
* user : username of the php-fpm process running owncloud
* packages : lists the packages to install owncloud as per the host linux distribution
* passwordsalt : salt that is used to randomize saved passwords in the owncloud database
* instanceid : an instance id that uniquely identifies and instance of owncloud
* mysql_password : is the password owncloud server uses to access mysql database
* mysql_user : username of owncloud user account inside the mysql database
* mysql_host : is the hostname of the server hosting the mysql server
* apache_vhost : is a boolean, if false it means you want to configure your own vhost, else if true means you want to the module to generate a vhost


Other customization or param modification can be made directly to 
```
manifest/server/params.pp
manifest/server/config.pp
templates/apache_vhost/subdirectory.erb
```

After the above application of the puppet manifest, there may be minor tweaking required such as
* file and directory ownership and permissions
* If and whether owncloud is able to create/re-associate the owncloud database
* The Owncloud config having the config hash of the mysql database
