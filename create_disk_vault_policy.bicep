//scope
targetScope = 'resourceGroup'
//Storage account for deployment scripts
var location = resourceGroup().location
param backupVaultName string
param policielist array
param type string


module createvault 'backup_disk_vault.bicep' = {
  name: 'diskvault'
  params: {
    backupVaultName: backupVaultName
    location: location
    type: type
  }
}

module createpolicy 'backup_disk_policy.bicep' = {
  name: 'diskpolicy'
  params: {
    policielist: policielist
    vaultName: createvault.outputs.vaultName
  }
  dependsOn: [
    createvault
  ]
}

