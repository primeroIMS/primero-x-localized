Security Hardening Playbook
============

Playbook utilizes [Ansible Collection - devsec.hardening](https://github.com/quoin/ansible-collection-hardening) for hardening the OS and SSH on a target server. This tool helps apply basic system hardening recommendations. This should not be considered an exhaustive list. Security is ultimately the local team's responsibility.

---
## Table of Contents

- [Security Hardening Playbook](#security-hardening-playbook)
  - [Table of Contents](#table-of-contents)
  - [Setup](#setup)
  - [Manual Hardening](#manual-hardening)
    - [Add Docker swap limit](#add-docker-swap-limit)
    - [Clean up unused containers](#clean-up-unused-containers)
    - [Firewall](#firewall)
  - [Scanning Tools](#scanning-tools)
  - [Reboot](#reboot)

---
## Setup

We recommend that you use a bastion server (a separate, small Ubuntu machine) to administer your Local Primero server. You should not be using a personal device to manage Primero.

Install the required tools on your bastion server. Note that Primero will require Python 3.8+

    sudo apt update
    sudo apt install git build-essential libssl-dev libffi-dev python-dev
    sudo apt install python3-pip
    sudo pip3 install virtualenv


Clone the repo and activate venv in order to run Ansible.

    git clone https://github.com/primeroIMS/primero-x-localized
    cd scripts/security-playbook/ansible
    bin/activate

Edit or create an inventory file in the `inventory/` dir. There will be an example file called `inventory.yml.template` that you can use.

    ---
    all:
      hosts:
        primero-example.org:
          ansible_user: ubuntu
        localhost:
          ansible_user: ubuntu

  ** Any overrides from the ansible-collection-hardening collection can be placed here.

Run the Ansible playbooks

    # Runs both os and ssh hardening
    ansible-playbook default.yml -l primero-example.org

    # Run only os hardening
    ansible-playbook os_hardening.yml -l primero-example.org

    # Run only ssh hardening
    ansible-playbook ssh_hardening.yml -l primero-example.org

These playbooks can be also applied to the Bastion server to improve the security on it:

    # Runs both os and ssh hardening
    ansible-playbook default.yml -l localhost

    # Run only os hardening
    ansible-playbook os_hardening.yml -l localhost

    # Run only ssh hardening
    ansible-playbook ssh_hardening.yml -l localhost
---

See [here](https://github.com/Quoin/ansible-collection-hardening/tree/master/roles/os_hardening) for the list of security items applied.

## Manual Hardening


### Add Docker swap limit

Run `docker info`. If it returns `WARNING: No swap limit support`, do the following:

    # Edit `/etc/default/grub` with sudo privileges and add or edit `GRUB_CMDLINE_LINUX` with the following

    `GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"`

Update GRUB

      sudo update-grub

Reboot server to reflect changes.

Read more about swap limits [here](https://docs.docker.com/engine/install/linux-postinstall/#your-kernel-does-not-support-cgroup-swap-limit-capabilities).

### Clean up unused containers

Periodically, you should clean up unused containers on the Local Primero server by running

      docker container prune -f

### Firewall

This playbook uses [nftables](https://www.nftables.org/projects/nftables/index.html) and [UFW](https://wiki.debian.org/Uncomplicated%20Firewall%20%28ufw%29). If you would like to set up the defaults for Primero, run the following:

    ansible-playbook os_hardening.yml -l primero-example.org --tags "use-ufw"


By default it will enable UFW, allow all outgoing, deny all incoming except ports 443, 22, and 80.

You can add additional ports/protocols to add by adding the following to your inventory file.

```
all:
  hosts:
    primero-example.org:
      ufw_allow_additional_incoming:
        - { port: $PORT, proto: $PROTOCOL }
```
 - $PROTOCOL - any | tcp | udp | esp | ah | gre | igmp

    ** Be aware that this playbook disables most of these protocols so you will have to make additional configuration changes if using any other than any or tcp.

You can also ssh into the server and add manually add ufw rules. Refer to https://help.ubuntu.com/community/UFW for more info.

Access on port 22 (SSH) should be permitted but restricted. We recommend whitelisting the IP of the local Bastion server and the UNICEF Primero X IP (provided by the UNICEF Primero team). See example below

```
all:
  hosts:
    primero-example.org:
      ufw_allow_additional_incoming:
        - { port: 22, proto: any, from_ip: <UNICEF-PRIMERO-X-IP1}
        - { port: 22, proto: any, from_ip: <UNICEF-PRIMERO-X-IP2}
        - { port: 22, proto: any, from_ip: <BASTION>}
```

---
## Scanning Tools

OS hardening playbook installs both [Lynis](https://cisofy.com/lynis/) and [Chkrootkit](http://www.chkrootkit.org/).

**Both packages should be ran from target machine and require sudo privileges**

Lynis is a security scanning package for linux

    sudo lynis audit system

Chkrootkit checks for signs of a rootkit

    sudo chkrootkit

The output of these scans will indicate remediation steps to the Local Team.

## Reboot

Certain change will require a system reboot to be applied.

    sudo reboot
