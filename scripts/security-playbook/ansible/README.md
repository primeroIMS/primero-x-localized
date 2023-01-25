Security Hardening Playbook
============

Playbook utilizes [Ansible Collection - devsec.hardening](https://github.com/dev-sec/ansible-collection-hardening) for hardening the os and ssh on a target server.

---
## Table of Contents

- [Setup](#setup)
- [Manual Hardening](#manual-hardening)
  - [Add docker swap limit](#add-docker-swap-limit)
- [Scanning Tools](#scanning-tools)

---
## Setup

Ensure you have the following installed:
  - Python 3: MacOS requires python 3.9
  - Pip
  - Virtualenv

Clone the repo and activate venv in order to run ansible.

    $ cd scripts/security-playbook/ansible
    $ bin/activate

Edit or create an inventory file in the `inventory` dir. There will be an example file called `inventory.yml.template` that you can use.

    ---
    all:
      hosts:
        primero-example.com:
          ansible_user: ubuntu

  ** Any overrides from the ansible-collection-hardening collection can be placed here.

Run the ansible playbooks

    # Runs both os and ssh hardening
    $ ansible-playbook default.yml -l $HOST

    # Run only os hardening
    $ ansible-playbook os_hardening.yml -l $HOST

    # Run only ssh hardening
    $ ansible-playbook ssh_hardening.yml -l $HOST

---
## Manual Hardening


### => Add docker swap limit 
https://docs.docker.com/engine/install/linux-postinstall/#your-kernel-does-not-support-cgroup-swap-limit-capabilities

Run `docker info`. If it returns `WARNING: No swap limit support`, do the following:

    # Edit `/etc/default/grub` with sudo privileges and add or edit `GRUB_CMDLINE_LINUX` with the following

    `GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"`

Update GRUB

      $ sudo update-grub

Reboot server to reflect changes

---
## Scanning Tools

This playbook installs both [Lynis](https://cisofy.com/lynis/) and [Chkrootkit](http://www.chkrootkit.org/).

**Both packages should be ran from target machine and require sudo privileges**

Lynis is a security scanning package for linux
    
    $ sudo lynis audit system

Chkrootkit checks for signs of a rootkit
    
    $ sudo chkrootkit







