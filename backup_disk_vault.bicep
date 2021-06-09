
param backupVaultName string
param location string
param type string //LocallyRedundant, GeoRedundant

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
output vaultName string = backupcontainer.name
