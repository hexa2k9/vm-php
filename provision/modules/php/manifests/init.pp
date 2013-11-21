class php (
    $version = "5.5.6",
    $path = "/usr/local/php"
) {
    Class["memcache"] -> Class["php"]

    exec { "php_dirs":
        command => "mkdir -p ${path} ${path}/src ${path}/log ${path}/run ${path}/lib ${path}/etc ${path}/conf.d ${path}/pool.d",
        creates => $path
    }

    exec { "php_download":
        command => "wget http://www.php.net/get/php-${version}.tar.gz/from/this/mirror -O php-${version}.tar.gz",
        cwd => "${path}/src",
        creates => "${path}/src/php-${version}.tar.gz",
        require => Exec["php_dirs"]
    }

    exec { "php_extract":
        command => "tar -xzvf php-${version}.tar.gz",
        cwd => "${path}/src",
        creates => "${path}/src/php-${version}/configure",
        require => Exec["php_download"]
    }

    file { "${path}/lib/php.ini":
        ensure => file,
        content => template("php/php.ini.erb"),
        require => Exec["php_extract"]
    }

    file { "${path}/etc/php-fpm.conf":
        ensure => file,
        content => template("php/php-fpm.conf.erb"),
        require => Exec["php_extract"]
    }

    file { "${path}/pool.d/www.conf":
        ensure => file,
        content => template("php/www.conf.erb"),
        require => File["${path}/etc/php-fpm.conf"]
    }

    exec { "php_dependencies":
        command => "sudo aptitude build-dep php5 -y",
        unless => "test -f ${path}/bin/php",
        timeout => 0,
        require => Exec["php_extract"]
    }

    exec { "php_make":
        command => template("php/configure.sh.erb"),
        timeout => 0,
        cwd => "${path}/src/php-${version}",
        creates => "${path}/bin/php",
        require => Exec["php_dependencies"]
    }

    exec { "php_dir_permissions":
        command => "chown -R vagrant:vagrant ${path}",
        require => Exec["php_make"]
    }

    exec { "php_initd":
        command => "cp -f /vagrant/provision/modules/php/files/php-fpm.init.d /etc/init.d/php-fpm && chmod 755 /etc/init.d/php-fpm && update-rc.d -f php-fpm defaults",
        creates => "/etc/init.d/php-fpm",
        require => Exec["php_dir_permissions"]
    }

    exec { "php_env_path":
        command => "echo \"PATH=/usr/local/php/bin:\\\$PATH\" >> /home/vagrant/.profile",
        require => Exec["php_initd"]
    }

    service { "php-fpm":
        ensure => running,
        subscribe => [
            File["${path}/lib/php.ini"],
            File["${path}/etc/php-fpm.conf"],
            File["${path}/pool.d/www.conf"]
        ]
    }

    php::pecl { "memcache":
        package => "http://pecl.php.net/get/memcache-3.0.8.tgz",
        phpInstallPath => $path,
        require => Exec["php_env_path"]
    }

    php::pecl { "uuid":
        package => "http://pecl.php.net/get/uuid-1.0.3.tgz",
        phpInstallPath => $path,
        require => Exec["php_env_path"]
    }

    php::pecl { "xhprof":
        package => "http://pecl.php.net/get/xhprof-0.9.4.tgz",
        phpInstallPath => $path,
        require => Exec["php_env_path"]
    }

    exec { "xhprof_ui":
        command => "git clone git://github.com/preinheimer/xhprof.git",
        cwd => "/var/www",
        creates => "/var/www/xhprof"
    }

    file { "/var/www/xhprof/runs":
        ensure => directory,
        require => Exec["xhprof_ui"]
    }

    file { "/usr/local/php/conf.d/xhprof.ini":
        content => template("php/xhprof.ini.erb"),
        ensure => file,
        require => Exec["xhprof_ui"],
        notify => Service["php-fpm"]
    }
}
