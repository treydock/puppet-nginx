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

  $site_conf          = "${nginx::params::nginx_sites_available}/${name}"
  $enabled_site_conf  = "${nginx::params::nginx_sites_enabled}/${name}"

  case $ensure {
    'present' : {
      nginx::install_site { $name:
        content => $content
      }
    }
    'absent' : {
      exec { "/bin/rm -f ${enabled_site_conf}":
        onlyif  => "/bin/sh -c '[ -L ${enabled_site_conf} ] && \
          [ ${enabled_site_conf} -ef ${site_conf} ]'",
        notify  => Service['nginx'],
        require => Package[$nginx::params::package_name],
      }
    }
    default: { err ("Unknown ensure value: '${ensure}'") }
  }
}
