# Polytene Runner #

## What is all about ##

* Its a part of Polytene infrastructure [Polytene](https://github.com/stricte/polytene)
* Inspired by [GitLab CI Runner](https://gitlab.com/gitlab-org/gitlab-ci-runner)


## Requirements ##

* Almost any kind of Linux distrbution
* Ruby >= 2.1.1


## Configuration ##

### Important things ###

1. **The most important is to run runners on seperate machine** and **each runner on seperate OS account**
2. **Before configuration make sure there is a Polytene panel up and running with at least one Runner created in it**

### Steps ###

* Create OS user `adduser polytene-runner-1 --disabled-login --home /var/local/polytene-runner-1`
* Generate SSH keys `ssh-keygen -t rsa -N '' -C 'Polytene Runner n1'` for this user and remember path to public key
* Clone Polytene Runner repo and chdir to it `git clone https://github.com/stricte/polytene-runner && cd polytene-runner`
* Run `bundle install`
* Run command to start configuration `./bin/polytene-runner configure`. Configurator will ask you few questions:
  * Polytene panel url - As it was mentioned, Polytene should be online already
  * Runner private token - created Runner in Polytene panel has it
  * Public SSH key path - you have generated keys few steps before

After successful configuration (Configurator will report about it), configurator will try to send _proof of live_ to Polytene panel. In POST request will be included SSH public key. This key will be stored in Polytene panel as one of the Runner's attributes. Use this as a authorized_key in machines where Runner will do the jobs.

## Running ##

* There are two ways:
  * Foreground: run command `./bin/polytene-runner start`. All output will be sent to STDOUT.
  * Background: run command `./bin/polytene-runner start -d`. Option -d stands for daemonize. Daemon will puts all output in repo tmp dir. PID file will be there too.

Its understandable that in most cases background method is prefered. So, to help with managing all Runners in local machine, init script is supplied in support dir.


## OS Integration ##

* Use init script located in `./support/polytene-runner.sh` to manage all Runners in machine. Each Polytene Runner need to have own conf file stored in `/etc/polytene-runner.d/` (name of each conf must ends with `conf`). Example is supplied in `./support/polytene-runner.d/polytene-runner-1.conf`


## LICENSE ##

See LICENSE file
