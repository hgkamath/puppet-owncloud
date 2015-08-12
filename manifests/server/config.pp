class owncloud::server::config {

  # do user before package 
  # Users::Account[$owncloud::server::user] -> Class['sickbeard::package']
  # $fcgi_port = 9006,

  $directory_ensure = $owncloud::server::ensure ? {
    present => link,
    default => $owncloud::server::ensure
  }

  $apache_vhostdir = {
        path => $owncloud::server::path,
        auth_require => 'ip 127.0.0.1 ::1 192.168.21.0/24',
        #order => 'Allow,Deny',
        #allow => 'from 127.0.0.1 ::1 192.168.21.0/24',
        options => ['ExecCGI', 'Includes', 'Indexes','FollowSymLinks','MultiViews'], 
   }
   $apache_custfrag =  template('owncloud/apache_vhost_subdirectory.erb')
   if (str2bool($owncloud::server::apache_vhost)) {
     apache::vhost { 'owncloud':
        ensure  => $owncloud::server::ensure,
        name => 'owncloud',
        docroot => $owncloud::server::path,
        port => '8080',
        directories => [ $apache_vhostdir, ],
        custom_fragment => $apache_custfrag,
     }
   }
  # nginx::vhost { "owncloud.${::fqdn}":
  #   root  => "${owncloud::server::path}/",
  # }
  # nginx::vhost::snippet { 'root':
  #   vhost   => "owncloud.${::fqdn}",
  #   content => template('owncloud/nginx_vhost.erb'),
  #   ensure  => $owncloud::server::ensure,
  #  }
  #nginx::vhost::snippet { 'owncloud':
  #  ensure  => $owncloud::server::ensure,
  #  vhost   => 'default',
  #  content => template('owncloud/nginx_vhost_subdirectory.erb'),
  #}

  mysql::db { $owncloud::server::mysql_database:
    user     => $owncloud::server::mysql_user,
    password => $owncloud::server::mysql_password,
    host     => $owncloud::server::mysql_host,
    grant    => ['all'],
  }


  #users::account  $owncloud::server::user:
  account { $owncloud::server::user:
    ensure   => $owncloud::server::ensure,
    uid      => 560,
    gid      => 560,
    home_dir => $owncloud::server::data_dir,
    shell    => '/bin/false',
    comment  => 'Owncloud',
  } ->


  
  #file { "/var/www/html_owncloud":
  #  ensure => directory,
  #  owner => "root",
  #  group => "root",
  #  mode => 755
  #}
  #file { '/var/www/html_owncloud/index.html':
  #  content => "<HTML>\n<HEAD>\n<TITLE>\nOwncloud HTTP server</TITLE>\n</HEAD>\n<BODY bgcolor=#ffffcc>\n<H1>Owncloud server</H1>\n<P>\n<A href=\"owncloud/\">Link</A>\n</BODY>\n</HTML>\n",
  #}
 ## apache::vhost { 'owncloud':
 ##   ensure  => $owncloud::server::ensure,
 ##   name => 'owncloud',
 ##   #docroot => '/var/www/html_owncloud',
 ##   docroot => '/usr/share/owncloud',
 ##   #scriptalias => '/var/www/cgi-bin',
 ##   #scriptalias => '/usr/share/cgi-bin',
 ##   port => '8080',
 ##   #aliases => [ { alias => '/', path => '/usr/share/owncloud' } ],
 # $owncloud_apache_vhostdir = {
 #   directories => [ {
 #       path => '/usr/share/owncloud',
 #       allow => 'from 127.0.0.1 ::1 192.168.21.0/24',
 #       options => ['ExecCGI', 'Includes', 'Indexes','FollowSymLinks','MultiViews'], 
      #},{
      #  path => '/var/www/html_owncloud',
      #  allow => 'from 127.0.0.1 ::1 192.168.21.0/24',
      #  options => ['ExecCGI', 'Includes', 'Indexes','FollowSymLinks','MultiViews'], 
#      } ],
#    custom_fragment => template('owncloud/apache_vhost_subdirectory.erb'),
    #ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://127.0.0.1:9006/usr/share/owncloud/$1'
    #proxy_pass => [], 
    #proxy_requests => 'On' , 
#    custom_fragment => '
#  DirectoryIndex index.php index.html
#  #ErrorDocument 403 /core/templates/403.php
#  #ErrorDocument 404 /core/templates/404.php
#  #ProxyPassMatch ^/(.*\.php.*)$ fcgi://127.0.0.1:9006/usr/share/owncloud/$1
#  RewriteCond %{REQUEST_URI} !index\.php$
#  RewriteCond %{REQUEST_URI} \.php
#  RewriteRule ^(/.*\.php(.*)?)$ fcgi://127.0.0.1:9006/usr/share/owncloud$1 [P]',
#  }
  # make sure data directory is writeble by php-fpm
  # the ensuring of account owncloud will set permissions
  #file { $owncloud::server::data_dir:
  #  ensure  => $owncloud::server::ensure,
  #  owner   => $owncloud::server::user,
  #  group   => $owncloud::server::user,
  #  mode    => '0600',
  #  recurse => true,
  #  force   => true
  #}

  file { '/etc/owncloud/':
    ensure  => $owncloud::server::ensure,
    owner   => $owncloud::server::user,
    group   => $owncloud::server::user,
    mode    => '0600',
    recurse => false,
    force   => true
  } ->

  file { '/etc/owncloud/config.php':
    ensure  => $owncloud::server::ensure,
    owner   => $owncloud::server::user,
    group   => $owncloud::server::user,
    mode    => '0640',
    recurse => false,
    replace => 'no',
    content => template('owncloud/config.php.erb'),
  } ->

  file { "${owncloud::server::path}/config":
    ensure => directory,
    owner => "owncloud",
    group => "owncloud",
    mode => "755"
  } ->
  file { "${owncloud::server::path}/config/config.php":
    ensure  => $directory_ensure,
    target  => '/etc/owncloud/config.php',
    force   => true,
    require => [Class['owncloud::server::package'], File['/etc/owncloud/config.php']],
  } ->
  file { "/var/lib/owncloud/tmp":
    ensure => directory,
    owner => "owncloud",
    group => "owncloud",
    mode => "755"
  } ->
  file { "/var/lib/owncloud/apps":
    ensure => directory,
    owner => "owncloud",
    group => "owncloud",
    mode => "755"
  } ->
  file { "/usr/share/owncloud/apps2":
    ensure => link,
    target => "/var/lib/owncloud/apps",
    owner => "owncloud",
    group => "owncloud",
    mode => "755"
  }
  # account creation will make this directory
  #file { "/var/lib/owncloud/data":
  #  ensure => directory,
  #  owner => "owncloud",
  #  group => "owncloud",
  #  mode => "750"
  #}

  #php::fpm::pool { 'owncloud':
  #  ensure  => $owncloud::server::ensure,
  #  port    => 9006,
  #  require => Users::Account[$owncloud::server::user]
  #}
  include php::fpm::daemon
  php::fpm::conf { 'owncloud':
    listen  => '127.0.0.1:9006',
    user    => 'owncloud',
    #php_settings         => [
    #  '#php_admin_flag[display_errors] = off',
    #  'php_admin_flag[log_errors] = on',
    #  "php_admin_value[error_log] = /var/log/php-fpm/owncloud-error.log",
    #  "#php_admin_value[memory_limit] = Dollar{memory_limit}",
    #  "#php_admin_value[date.timezone] = Dollar{time_zone}",
    #  "php_admin_value[session.save_path]=/var/lib/owncloud/tmp"
    #],
    php_flag => {
      "zlib.output_compression" => "off",
    },
    php_admin_flag => {
      #"log_errors" => "on",
    },
    php_admin_value => {
      #"error_log" => "/var/log/php-fpm/owncloud-error.log", 
      "session.save_path" => "/var/lib/owncloud/tmp",
      "always_populate_raw_post_data" => "-1",
      "upload_max_filesize" => "512mb",
      "post_max_filesize" => "512mb",
    },
    require => Package['httpd'],
  }

  cron { 'owncloud cron':
    command => "/usr/bin/php ${owncloud::server::path}/cron.php >/tmp/owncloud_cron_output.txt 2>&1",
    user    => $owncloud::server::user,
    hour    => '*',
    minute  => '*',
    require => User[$owncloud::server::user],
  }

}
