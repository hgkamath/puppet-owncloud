# Class: owncloud::server::params
#
# This class defines default parameters used by the main module class phpmyadmin
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to owncloud::server class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class owncloud::server::params {

  ### Application related parameters

  $packages = $::operatingsystem ? {
    default => [ 'mariadb-server' , 'owncloud'   , 'php-fpm' ]
  }

  $path = '/usr/share/owncloud'
  $data_dir = '/var/lib/owncloud/data'

  $user           = 'owncloud'
  $passwordsalt   = undef
  $mysql_database = 'owncloud'
  $mysql_user     = 'owncloud'
  $mysql_host     = 'localhost'
  $apache_vhost   = false

  $enabled = true

}
