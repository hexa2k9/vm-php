define php::pecl (
    $phpInstallPath,
    $package = undef
) {
    if $package == undef {
        $package = $name
    }

    exec { "install_pecl_${name}":
        command => "sudo ${phpInstallPath}/bin/pecl install ${package} && echo \"extension=${name}.so\" > ${phpInstallPath}/conf.d/${name}.ini",
        cwd => "${phpInstallPath}/bin",
        user => "vagrant",
        unless => "${phpInstallPath}/bin/pecl list | grep ${name}",
        notify => Service["php-fpm"]
    }
}
