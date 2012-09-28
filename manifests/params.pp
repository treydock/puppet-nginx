class nginx::params {

  case $::osfamily {
    'RedHat': {
      $package_name                   = 'nginx'
      $service_name                   = 'nginx'
      $nginx_user_default             = 'nginx'
      $nginx_conf_dir                 = '/etc/nginx'
      $nginx_conf_path                = "${nginx_conf_dir}/nginx.conf"
      $nginx_includes_dir             = "${nginx_conf_dir}/includes"
      $nginx_confd_dir                = "${nginx_conf_dir}/conf.d"
      $nginx_sites_enabled            = "${nginx_conf_dir}/conf.d"
      $nginx_sites_available          = "${nginx_conf_dir}/conf.d"
#      $nginx_inc_dirs                 = [ $nginx_conf ]
      $docroot_base_dir               = '/var/www'
      # Configuration defaults
      $nginx_worker_processes_default = '1'
      $nginx_worker_connections_real  = '1024'
    } 

    'Debian': {
      $package_name                   = 'nginx'
      $service_name                   = 'nginx'
      $nginx_user_default             = 'www-data'
      $nginx_conf_dir                 = '/etc/nginx'
      $nginx_conf_path                = "${nginx_conf_dir}/nginx.conf"
      $nginx_includes_dir             = "${nginx_conf_dir}/includes"
      $nginx_confd_dir                = "${nginx_conf_dir}/conf.d"
      $nginx_sites_enabled            = "${nginx_conf_dir}/sites-enabled"
      $nginx_sites_available          = "${nginx_conf_dir}/sites-available"
#      $nginx_inc_dirs                 = [ $nginx_conf, $nginx_sites_enabled ]
      $docroot_base_dir               = '/var/www'
      # Configuration defaults
      $nginx_worker_processes_default = '1'
      $nginx_worker_connections_real  = '1024'
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only supports osfamily RedHat and Debian")
    }
  }

}
