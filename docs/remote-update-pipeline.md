# Remote Update Pipeline

This pipeline in azure is used to update remote instances

## Updating

1. Make your changes to your inventory file in `primero-x-devops/releases_remote`
2. Create a pr into master. Once merged, the update pipeline should run and deploy your changes.

## Force Updating

1. Run the remote update pipeline. Make sure to set `FORCE_DEPLOY` to true and `DEPLOY_IMPLEMENTATION` to the file name of the inventory file minus the extention. (ex: `poc-primero` for `poc-primero.inventory.yml`) This will force deploy the poc-primero remote instance.
