# Remote Onboarding Pipeline

This pipeline in azure is used to onboard new remote instances

## Requirements

### The following is required before running the pipeline.

#### Provided by the individual performing onboarding
- [ ] Build agent ip address to be whitelisted by remote server

#### Provided by you
- [ ] Sudoless server user with ssh access
- [ ] Properly setup dns. Provide hostname.
- [ ] Provide if you will use an external postgresql database, If not, a database will be created via docker with generated credentials.
- [ ] Configuration version/branch and path in repo
- [ ] Languages to configure
- [ ] From email address to use for mailer
- [ ] Whether or not you are using let's encrypt, if not provide the path to the certs
- [ ] Do you want to show the code of conduct, or data protection ui
- [ ] Onboarding agency, email, and full name
- [ ] Admin name, email (used for certbot if using let's encrypt)
- [ ] A `overrides.env` file will be created when onboarding the first time. You can also create this file before hand. If using a external postgres database this file is needed before the onboarding process can begin. Create a `overrides.env` somewhere and provide the path to that file. This file is used to configure smtp, postgres, and storage.
  
  Notes
  * External database should have a user that has admin privledges. 
  * Provide the version of postgres if using an external database
  <br /><br />

  ```
  # SMTP overrides
  #SMTP_ADDRESS=
  #SMTP_PORT=
  #SMTP_DOMAIN=
  #SMTP_AUTH=
  #SMTP_STARTTLS_AUTO=

  # Posgresql database overrides
  #POSTGRES_DATABASE=
  #POSTGRES_USER=
  #POSTGRES_PASSWORD=
  #POSTGRES_HOSTNAME=
  #POSTGRES_SSL_MODE=
  #POSTGRES_POOL_NUM=

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

  ...
  ```

You can also provide any of this information to the onboarder.

## Pipeline Library Variables

| Variable | Description |
| --- | --- |
| ANSIBLE_TAG | Primero branch to use for ansible. **Only set for pipeline development** |
| ANSIBLE_USER | Sudoless user on remote machine |
| CONFIGURATION_REPO_GIT_REVISION | Configuration tag/branch |
| ENV_OVERRIDE_PATH |  Path to overrides.env on remote server |
| GITOPS_BRANCH | primero-x-devops branch. **Only change for pipelne development** |
| IMAGE_TAG | Version of primero to use. Version should exist in dockerhub |
| MAILER_DEFAULT_FROM | Mailer from to use for smtp |
| NGINX_SSL_CERT_PATH | Path to ssl cert |
| NGINX_SSL_KEY_PATH | Path to ssl key |
| POSTGRES_CLIENT_VERSION | Postgres version (10\|11\|14) |
| PRIMERO_CODE_OF_CONDUCT | Display code of conduct ui (true\|false) |
| PRIMERO_DATA_PROTECTION_CASE_CREATION | Display data protection ui (true\|false) |
| PRIMERO_DEPLOY_NODB | Bypass creation of a docker db (true\|false) |
| PRIMERO_HOSTNAME | Primero hostname |
| PRIMERO_LOCALES | Languages to use in primero, (comma seperated iso codes) |
| PRIMERO_ONBOARDING_ADMIN_AGENCY_CODE | Admin agency |
| PRIMERO_ONBOARDING_ADMIN_AGENCY_NAME | Admin name |
| PRIMERO_ONBOARDING_ADMIN_EMAIL | Admin email address |
| PRIMERO_ONBOARDING_ADMIN_FULL_NAME | Admin full name |
| PRIMERO_SAAS_ADMIN_EMAIL | Email address of server admin |
| RELATIVE_CONFIGURATION_PATH | Path to configuration in git repo |
| USE_LETS_ENCRYPT | Use Let's Encrypt (true\|false) |

## Onboarding

1. Fill out the library variables for remote-prod-pipeline-variables
2. Ensure everything needed is in place
3. Run remote onboarding pipeline (Select master branch, remote-prod-pipeline-variables variables group)
