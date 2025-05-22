# Primero Localized

UNICEF is extending its hosted Primero service to deliver "Primero Tier 4", a hybrid cloud package of services for operating Primero. This delegates the responsibility for managing the physical infrastructure to local country teams while keeping the responsibility for managing and operating Primero services with UNICEF.

This repository contains documentation and tools that a local team can use to build a server that can be integrated with Primero Tier 4. We will refer to this server as "Localized Primero."

This documentation contains the following sections:
- [Preparing your server for connection to Primero](docs/remote-onboarding-pipeline.md)
- [Security hardening](docs/security.md)
- [Day-to-day operations](docs/operations.md)
- [A sample approach for Primero database backups](docs/backup.md)
- [Server Upgrade: Ubuntu 20.04 → 24.04](docs/upgrade-ubuntu.md)

## Contributing

Local teams may wish to share their experience with setting up Localized Primero servers. The Primero Team welcomes their input. We will work to incorporate proposed best practices for Localized Primero server configuration into this guide.

## Advisory notes
Given that the apt package manage of Ubuntu runs slightly behind the latest version of any package it may be necessary to download the lynis package from source and run the utility from there to get a more thorough system audit.

## OS Major Release Upgrade notes
Ubuntu requires that major release upgrades follow the natural upgrade process, i.e. to upgrade from 20.04 to 24.04 there is the step to upgrade 20.04 to 22.04 and then another upgrade is required to upgrade from 22.04 to 24.04. As part of the hardening process, configuration files are modified for the openssh package. This package is also modified during the Ubuntu upgrade process. Unless carefully managed, inconsistencies between the Ubuntu upgrade and security changes may misconfigure the SSH process, and may lead to loss of access to the production server.