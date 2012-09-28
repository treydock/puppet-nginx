class nginx::params {

  case $::osfamily {
    'RedHat': { 
      $nginx_conf_dir         = '/etc/nginx'
      $nginx_includes         = "${nginx_conf_dir}/includes"
      $nginx_conf             = "${nginx_conf_dir}/conf.d"
      $nginx_sites_enabled    = "${nginx_conf_dir}/conf.d"
      $nginx_sites_available  = "${nginx_conf_dir}/conf.d"
      $nginx_inc_dirs         = [ $nginx_conf ]
      $docroot_base_dir       = '/var/www'
    } 

    'Debian': {
      $nginx_conf_dir         = '/etc/nginx'
      $nginx_includes         = "${nginx_conf_dir}/includes"
      $nginx_conf             = "${nginx_conf_dir}/conf.d"
      $nginx_sites_enabled    = "${nginx_conf_dir}/sites-enabled"
      $nginx_sites_available  = "${nginx_conf_dir}/sites-available"
      $nginx_inc_dirs         = [ $nginx_conf, $nginx_sites_enabled ]
      $docroot_base_dir       = '/var/www'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only supports osfamily RedHat and Debian")
    }
  }

}
