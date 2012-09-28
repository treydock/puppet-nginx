# Define: install_site
#
# Install nginx vhost
# This definition is private, not intended to be called directly
#
define nginx::install_site($content=undef) {
  include nginx::params

  $site_conf = "${nginx::params::nginx_sites_available}/${name}"

  # first, make sure the site config exists
  case $content {
    undef: {
      file { $site_conf:
        ensure  => present,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        alias   => "sites-${name}",
        notify  => Service['nginx'],
        require => Package[$nginx::params::package_name],
      }
    }
    default: {
      file { $site_conf:
        ensure  => present,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        alias   => "sites-$name",
        content => $content,
        notify  => Service['nginx'],
        require => Package[$nginx::params::package_name],
      }
    }
  }

  if $::osfamily == 'Debian' {
    # now, enable it.
    exec { "ln -s ${nginx_sites_available}/${name} ${nginx_sites_enabled}/${name}":
      unless  => "/bin/sh -c '[ -L ${nginx_sites_enabled}/${name} ] && \
        [ ${nginx_sites_enabled}/${name} -ef ${nginx_sites_available}/${name} ]'",
      path    => ['/usr/bin/', '/bin/'],
      notify  => Service['nginx'],
      require => File["sites-${name}"],
    }
  }
}
