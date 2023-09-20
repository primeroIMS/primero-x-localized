# Local Onboard

Primero is deployed to the local server via Ansible, triggered by an Azure pipeline which is part of UNICEF's Primero X service.

## Requirements

### The following is required before running a local onboard.

#### Provided by the UNICEF Primero Team
- [ ] UNICEF's Primero X Agent IP addresses.

#### Provided by the Local Team
- [ ] Default firewall rules

  ** Order of these rules is important. Use the order below.
  - Open port 80, 443.
  - The Primero X Agent IPs must be whitelisted by the remote server for SSH connections over port 22.
  - Allow port 22 for authorized IPs.
  - Deny all other access on port 22.
  - Allow all outbound traffic.
  - Deny all inbound traffic.
- [ ] Password-less server user with sudo privileges and SSH access. Confirm by logging into your server using `sudo -l`
  ```
  Sample output:
    User [host-user] may run the following commands on [host]:
    (ALL) NOPASSWD: ALL
  ```
- [ ] Properly setup DNS. Provide hostname.
- [ ] Indicate if you will use an external PostgreSQL database. If not, a database will be created via Docker with generated credentials (not recommended).
- [ ] The baseline configurations template choice: (CP-IA, GBV). Configurations are staged in UNICEF's primero-x-configuration Git repo. If this onboard is a migration from Tier 3, pick the template that is closest to your current configuration.
- [ ] Primero Languages (locales)
- [ ] The email address that Primero system email notifications will be sent from (see below for SMTP details).
- [ ] Choose if your implementation will use a procured TLS Certificate or [Let's Encrypt](https://letsencrypt.org/). If you are using a procured certificate, it will need to be staged on the local Primero server.
  - [ ] If using Let's Encrypt, provide an IT administrator's name and email for contact if there is a problem with Let'S Encrypt issued certificates.
  - [ ] If using a procured certificate, run `mkdir -p /srv/external-certs` and place them in the `/srv/external-certs` directory on the target machine. This must be done before onboarding an instance. Both files (cert and key) must have 755 permission.
- [ ] Indicate if the implementation will show the code of conduct or data protection notifications.
- [ ] The onboarding administrator's agency, email, and full name.
- [ ] An `overrides.env` needs to be created in the user home directory (usually `/home/ubuntu/overrides.env`) on the Primero server before the onboard. This file is used to configure SMTP, PostgreSQL, WebPush, and storage. The permissions for the file should be 600. `chmod 600 ~/overrides.env`

  Notes:
  * External database should have a user that has admin privileges.
  * TODO: Provide the version of PostgreSQL if using an external database
  * If you are enabling webpush, add PRIMERO_WEBPUSH, PRIMERO_WEBPUSH_VAPID_PRIVATE and PRIMERO_WEBPUSH_VAPID_PUBLIC in overrides file, then run pipeline either onboard or update. To generate valid VAPID keys, check the steps in [primero README](https://github.com/primeroIMS/primero/blob/main/README.md#using-webpush) file.
  <br /><br />

  ```
  # SMTP overrides
  SMTP_ADDRESS=
  SMTP_PORT=
  SMTP_DOMAIN=
  # Usually SMTP_AUTH=login
  SMTP_AUTH=
  SMTP_USER=
  SMTP_PASSWORD=
  SMTP_STARTTLS_AUTO=true

  # Posgresql database overrides
  POSTGRES_DATABASE=
  POSTGRES_USER=
  POSTGRES_PASSWORD=
  POSTGRES_HOSTNAME=
  POSTGRES_SSL_MODE=
  POSTGRES_POOL_NUM=

  # Options are microsoft, local, aws, amazon, minio
  PRIMERO_STORAGE_TYPE=

  # Local storage overrides
  #PRIMERO_STORAGE_PATH=

  # Azure storage overrides
  #PRIMERO_STORAGE_AZ_ACCOUNT=
  #PRIMERO_STORAGE_AZ_KEY=
  #PRIMERO_STORAGE_AZ_CONTAINER=

  # AWS storage overrides
  #PRIMERO_STORAGE_AWS_ACCESS_KEY=
  #PRIMERO_STORAGE_AWS_SECRET_ACCESS_KEY=
  #PRIMERO_STORAGE_AWS_REGION=
  #PRIMERO_STORAGE_AWS_BUCKET=

  # Minio storage overrides
  #PRIMERO_STORAGE_MINIO_ACCESS_KEY=
  #PRIMERO_STORAGE_MINIO_SECRET_ACCESS_KEY=
  #PRIMERO_STORAGE_MINIO_REGION=
  #PRIMERO_STORAGE_MINIO_BUCKET=
  #PRIMERO_STORAGE_MINIO_ENDPOINT=

  # WebPush Notifications
  #PRIMERO_WEBPUSH=
  #PRIMERO_WEBPUSH_VAPID_PRIVATE=
  #PRIMERO_WEBPUSH_VAPID_PUBLIC=
  ...
  ```
## Pipeline Library Variables

These are filled out by the UNICEF Primero team to configure the Primero X onboard.

| Variable | Description |
| --- | --- |
| ANSIBLE_TAG | Primero branch to use for ansible. **Only set for pipeline development** |
| ANSIBLE_USER | Sudoless user on remote machine |
| CONFIGURATION_REPO_GIT_REVISION | Configuration tag/branch |
| ENV_OVERRIDE_PATH |  Path to overrides.env on remote server |
| GITOPS_BRANCH | primero-x-devops branch. **Only change for pipeline development** |
| IMAGE_TAG | Version of primero to use. Version should exist in Dockerhub |
| MAILER_DEFAULT_FROM | Mailer from to use for smtp |
| NGINX_SSL_CERT_PATH | Path to tls cert on remote server. <br>Set to `/etc/letsencrypt/live/primero/fullchain.pem` if using Let's Encrypt. <br>Set to `/external-certs/$CERT_FILE` if using external tls. |
  | NGINX_SSL_KEY_PATH | Path to tls key on remote server. <br>Set to `/etc/letsencrypt/live/primero/privkey.pem` if using Let's Encrypt. <br> Set to `/external-certs/$KEY_FILE` if using external tls. |
| POSTGRES_CLIENT_VERSION | Postgres version (10\|11\|14) |
| PRIMERO_CODE_OF_CONDUCT | Display code of conduct ui (true\|false) |
| PRIMERO_DATA_PROTECTION_CASE_CREATION | Display data protection ui (true\|false) |
| PRIMERO_DEPLOY_NODB | Set to `true` to deploy using an external database. <br>Set to `false` to run the database in Docker |
| PRIMERO_HOSTNAME | Primero hostname |
| PRIMERO_LOCALES | Languages to use in Primero, (comma separated iso codes) |
| PRIMERO_ONBOARDING_ADMIN_AGENCY_CODE | Admin agency |
| PRIMERO_ONBOARDING_ADMIN_AGENCY_NAME | Admin name |
| PRIMERO_ONBOARDING_ADMIN_EMAIL | Admin email address |
| PRIMERO_ONBOARDING_ADMIN_FULL_NAME | Admin full name |
| PRIMERO_SAAS_ADMIN_EMAIL | Email address of server admin |
| RELATIVE_CONFIGURATION_PATH | Path to configuration in git repo |
| USE_LETS_ENCRYPT | Use Let's Encrypt (true\|false) |
