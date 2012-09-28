# Define: nginx::fcgi::site
#
# Create a fcgi site config from template using parameters.
# You can use my php5-fpm class to manage fastcgi servers.
#
# Parameters :
# * ensure: typically set to "present" or "absent". Defaults to "present"
# * root: document root (Required)
# * fastcgi_pass : port or socket on which the FastCGI-server is listening (Required)
# * server_name : server_name directive (could be an array)
# * listen : address/port the server listen to. Defaults to 80. Auto enable ssl if 443
# * access_log : custom acces logs. Defaults to /var/log/nginx/$name_access.log
# * include : custom include for the site (could be an array). Include files must exists
#   to avoid nginx reload errors. Use with nginx::site_include
# * ssl_certificate : ssl_certificate path. If empty auto-generating ssl cert
# * ssl_certificate_key : ssl_certificate_key path. If empty auto-generating ssl cert key
#   See http://wiki.nginx.org for details.
#
# Templates :
# * nginx/fcgi_site.erb
#
# Sample Usage :
#   nginx::fcgi::site { 'default':
#     root         => '/var/www/nginx-default',
#     fastcgi_pass => '127.0.0.1:9000',
#     server_name  => ['localhost', $hostname, $fqdn],
#   }
#
#   nginx::fcgi::site { 'default-ssl':
#     listen          => '443',
#     root            => '/var/www/nginx-default',
#     fastcgi_pass    => '127.0.0.1:9000',
#     server_name     => $fqdn,
#   }
#
define nginx::fcgi::site(
  $root,
  $fastcgi_pass,
  $ensure              = 'present',
  $index               = 'index.php',
  $include             = '',
  $listen              = '80',
  $server_name         = undef,
  $access_log          = undef,
  $ssl_certificate     = undef,
  $ssl_certificate_key = undef,
  $ssl_session_timeout = '5m') {
  include nginx::params

  $ssl_certificate_dir          = "${nginx::params::nginx_conf_dir}/ssl"
  $ssl_certificate_default      = "${ssl_certificate_dir}/${name}.pem"
  $ssl_certificate_key_default  = "${ssl_certificate_dir}/${name}.key"

  $server_name_real = $server_name ? {
    undef   => $name,
    default => $server_name,
  }

  $access_log_real = $access_log ? {
    undef   => "/var/log/nginx/${name}_access.log",
    default => $access_log,
  }

  $ssl_certificate_real = $ssl_certificate ? {
    undef   => $ssl_certificate_default,
    default => $ssl_certificate,
  }

  $ssl_certificate_key_real = $ssl_certificate_key ? {
    undef   => $ssl_certificate_key_default,
    default => $ssl_certificate_key,
  }

  # Autogenerating ssl certs
  if $listen == '443' and  $ensure == 'present' and ($ssl_certificate_real == undef or $ssl_certificate_key_real == undef) {
    exec { "generate-${name}-certs":
      command => "/usr/bin/openssl req -new -inform PEM -x509 -nodes -days 999 -subj \
        '/C=ZZ/ST=AutoSign/O=AutoSign/localityName=AutoSign/commonName=${server_name_real}/organizationalUnitName=AutoSign/emailAddress=AutoSign/' \
        -newkey rsa:2048 -out ${ssl_certificate_real} -keyout ${ssl_certificate_key_real}",
      unless  => "/usr/bin/test -f ${ssl_certificate_real}",
      require => File[$ssl_certificate_dir],
      notify  => Service['nginx'],
    }
  }

  nginx::site { $name:
    ensure  => $ensure,
    content => template('nginx/fcgi_site.erb'),
  }
}

