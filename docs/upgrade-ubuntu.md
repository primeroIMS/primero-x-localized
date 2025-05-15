# Server Upgrade: Ubuntu 20.04 → 24.04

Warning
-------

Upgrading a production server is a high-risk operation. During the upgrade process:
*   The server may become inaccessible due to broken configurations or network issues.

*   SSH connectivity might be lost, and in worst-case scenarios, you could get locked out of the system.

**Creating snapshots and backups is mandatory before proceeding.**


Prerequisites
----------------

### 1. Create Backups

*   **VM Snapshot** from Azure Portal or your cloud provider.

*   **Database Backup** (e.g., using `pg_dump` for PostgreSQL).

*   **Attachments Backup**.

*   **Store all backups in a secure, offsite location.**


### 2. Configure SSH Keep-Alive

On your local machine or bastion host, edit your `~/.ssh/config` file. If the entry for the target server already exists, add the following line under it:

      ServerAliveInterval 20

If it doesn't exist yet, add a new block like this:

    Host your-target-server
      HostName your.target.ip
      User your-user
      ServerAliveInterval 20

This prevents SSH session from timing out during the upgrade process.


Upgrade Steps
-------------

### Step 1: System Preparation

    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove --purge -y

### Step 2: Upgrade ubuntu from 20.04 to 22.04

    sudo do-release-upgrade

*   Carefully review and answer any prompts during the upgrade(see Package Configuration Choices section below).

### Step 3: Upgrade  ubuntu from 22.04 to 24.04

    sudo do-release-upgrade

*   Again, follow on-screen prompts and review suggested changes(see Package Configuration Choices section below).


* * *

Package Configuration Choices
-----------------------------

During the upgrade, you may be prompted to keep or replace configuration files. Follow these recommendations:
| File | Recommended Action |
| --- | --- |
| `/etc/login.defs` | `Y` Install the package maintainer's version |
| `/etc/sudoers` | `N` Keep current version |
| `/etc/audit/audit.conf` | `Y` Install the package maintainer's version |
| `/etc/sysctl.conf` | `Y` Install the package maintainer's version |
| `/etc/ssh/ssh_config` | `Y` Install the package maintainer's version |
| `/etc/ssh/moduli` | `Y` Install the package maintainer's version |
| `/etc/ssh/sshd_config` | `Y` Install the package maintainer's version |
| `/etc/default/useradd` | `Y` Install the package maintainer's version |
| `chrony.conf` | `Y` Install the package maintainer's version |
| Postfix Configuration | `No Configuration` |
| libc6, libpam-modules, etc. | Read and accept |

* * *

Troubleshooting
------------------

### Locked Out of Server (Azure)

If you're using Azure and become locked out:
1.  Go to the Azure Portal.

2.  Select your Virtual Machine.

3.  Navigate to **"Reset password"**.

4.  Choose the **"Reset configuration only"** tab.

This resets only network and SSH settings without affecting disks or users.