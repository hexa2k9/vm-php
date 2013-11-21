# Development Server

This repository contains [Puppet][puppet] scripts to quickly create a development server
running the following software:

* nginx
* PHP 5.5.6
* MySQL
* memcached
* xhprof

## Overview

The purpose of these scripts is to create a development environment for a single website or application.
In the future, I hope to abstract these Puppet scripts into a more modular form. For now, they suit
my own immediate needs.

## Getting Started

1. Clone this repository to your computer
2. Specify your MySQL database settings in `provision/modules/mysql/manifests/params.pp`
3. Specify your nginx website domain in `provision/modules/nginx/manifests/params.pp`
4. Run `vagrant up`

After the virtual machine is running, you should update your `/etc/hosts` file to point your website's
domain name to `192.168.33.10`. You can access the development website on port `8080` and
the xhprof UI on port `8081`.

## How to Contribute

1. Fork this repository
2. Create a new branch for each feature or improvement
3. Send a pull request from your feature branch

It is very important to separate new features or improvements into separate feature branches, and to send a
pull request for each branch. This allows us to review and pull in new features or improvements individually.

## Requirements

You'll need the following software installed on your local machine:

* VirtualBox
* Vagrant
* Terminal/Console

## Copyright

Copyright 2013, [Josh Lockhart][josh]

## License

MIT Public License

[puppet]: http://puppetlabs.com/
[josh]: http://www.joshlockhart.com/
