# Class: nginx
#
# Install nginx.
#
# Parameters:
# * $nginx_user. Defaults to Debian: 'www-data', RedHat: 'nginx'.
# * $nginx_worker_processes. Defaults to '1'.
# * $nginx_worker_connections. Defaults to '1024'.
#
# Create config directories :
# * /etc/nginx/conf.d for http config snippet
# * /etc/nginx/includes for sites includes
#
# Provide 3 definitions :
# * nginx::config (http config snippet)
# * nginx::site (http site)
# * nginx::site_include (site includes)
#
# Templates:
#   - Debian: nginx.conf.erb => /etc/nginx/nginx.conf
#   - RedHat: nginx.conf.rhel.erb => /etc/nginx/nginx.conf
#
class nginx {
  include nginx::params

  $nginx_user_real = $::nginx_user ? {
    undef   => $nginx::params::nginx_user_default,
    default => $::nginx_user
  }

  $nginx_worker_processes_real = $::nginx_worker_processes ? {
    undef   => $nginx::params::nginx_worker_processes_default,
    default => $::nginx_worker_processes
  }

  $nginx_worker_connections_real = $::nginx_worker_connections ? {
    undef   => $nginx::params::nginx_worker_connections_default,
    default => $::nginx_worker_connections
  }

  if ! defined(Package[$nginx::params::package_name]) { package { $nginx::params::package_name: ensure => installed }}

  #restart-command is a quick-fix here, until http://projects.puppetlabs.com/issues/1014 is solved
  service { $nginx::params::service_name:
    ensure      => running,
    enable      => true,
    hasrestart  => true,
    require     => File[$nginx::params::nginx_conf_path],
    restart     => '/etc/init.d/nginx reload',
    alias       => 'nginx', # Allow external modules to notify independent of service_name change
  }

  file { $nginx::params::nginx_conf_path:
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template($nginx::params::nginx_conf_template),
    notify  => Service['nginx'],
    require => Package[$nginx::params::package_name],
  }

  file { [ "${nginx::params::nginx_conf_dir}/ssl",
            $nginx::params::nginx_confd_dir,
            $nginx::params::nginx_includes_dir ]:
    ensure  => directory,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Package[$nginx::params::package_name],
  }

  # Nuke default files
  file { "${nginx::params::nginx_conf_dir}/fastcgi_params":
    ensure  => absent,
    require => Package[$nginx::params::package_name],
  }

  # Create base directory for web roots
  file { $nginx::params::docroot_base_dir:
    ensure  => directory,
    require => Package[$nginx::params::package_name],
  }
}
