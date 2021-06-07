
param backupVaultName string
param location string
param type string //LocallyRedundant, GeoRedundant
var dataProtectionUniqueId = guid(resourceGroup().id, resourceGroup().name)
var DiskBackupSnapShot = '7efff54f-a5b4-42b5-a1c5-5411624893ce'
resource backupcontainer 'Microsoft.DataProtection/backupVaults@2021-02-01-preview' = {
  name: backupVaultName
  identity:{
    type: 'SystemAssigned'
  }
  location: location
  properties: {
    storageSettings: [
      {
        datastoreType:'VaultStore'
        type: type
      }
    ]
  } 
}

resource roleassign4RG 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: dataProtectionUniqueId
  properties: {
    principalId: backupcontainer.identity.principalId
    roleDefinitionId: '${resourceGroup().id}/providers/Microsoft.Authorization/roleDefinitions/${DiskBackupSnapShot}'
  }
}
output vaultName string = backupcontainer.name
