# Define: nginx::site_include
#
# Define a site config include in /etc/nginx/includes
#
# Parameters :
# * ensure: typically set to "present" or "absent". Defaults to "present"
# * content: include definition (should be a template).
#
define nginx::site_include($ensure='present', $content='') {
  include nginx::params

  file { "${nginx::params::nginx_includes_dir}/${name}.inc":
    ensure  => $ensure,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => $content,
    require => File[$nginx::params::nginx_includes_dir],
    notify  => Service['nginx'],
  }
}