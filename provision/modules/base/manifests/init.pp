class base {
    exec { "apt-update":
        command => "sudo apt-get update"
    }

    package { "base-packages":
        name => [
            "git",
            "strace",
            "wget",
            "unzip",
            "build-essential",
            "libmcrypt-dev"
        ],
        ensure => present,
        require => Exec["apt-update"]
    }
}
