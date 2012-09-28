# Define: nginx::site
#
# Install a nginx site in /etc/nginx/sites-available (and symlink in /etc/nginx/sites-enabled) for Debian.
# Install a nginx site in /etc/nginx/conf.d for RedHat.
#
#
# Parameters :
# * ensure: typically set to "present" or "absent". Defaults to "present"
# * content: site definition (should be a template).
#
define nginx::site($ensure='present', $content='') {
  include nginx::params

  case $ensure {
    'present' : {
      nginx::install_site { $name:
        content => $content
      }
    }
    'absent' : {
      exec { "/bin/rm -f ${nginx_sites_enabled}/${name}":
        onlyif  => "/bin/sh -c '[ -L ${nginx_sites_enabled}/${name} ] && \
          [ ${nginx_sites_enabled}/${name} -ef $nginx_sites_available/${name} ]'",
        notify  => Service['nginx'],
        require => Package[$nginx::params::package_name],
      }
    }
    default: { err ("Unknown ensure value: '$ensure'") }
  }
}
