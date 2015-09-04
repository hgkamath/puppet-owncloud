

# Install and configure an owncloud server
# default parameters are retrieved from owncloud::server::params
class owncloud::server(
  $packages       = [ 'mariadb-server' , 'owncloud'   , 'php-fpm' ],
  $path           = $owncloud::server::params::path,
  $data_dir       = $owncloud::server::params::data_dir,
  $user           = $owncloud::server::params::user,
  $passwordsalt   = $owncloud::server::params::passwordalt,
  $mysql_database = $owncloud::server::params::mysql_database,
  $mysql_user     = $owncloud::server::params::mysql_user,
  $mysql_password = $owncloud::server::params::mysql_password,
  $mysql_host     = $owncloud::server::params::mysql_host,
  $apache_vhost   = $owncloud::server::params::apache_vhost,
  $instanceid     = $owncloud::server::params::instanceid,
  $enabled        = $owncloud::server::params::enabled
  ) inherits owncloud::server::params {

    $ensure = $enabled ? {
      true => present,
      false => absent
    }

  include owncloud::server::package, owncloud::server::config
}
