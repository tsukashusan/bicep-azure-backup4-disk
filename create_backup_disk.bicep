//scope
targetScope = 'resourceGroup'
//Storage account for deployment scripts
param backupInstanceNameArray array
param dataSourceInfoArray array
param objectTypeArray array
param dataSourceSetInfoArray array
param policyName string
param vaultName string
param principalId string

module createvault 'backup_disk_instance.bicep' = {
  name: 'backupdisk'
  params: {
    backupInstanceNameArray: backupInstanceNameArray
    dataSourceInfoArray: dataSourceInfoArray
    objectTypeArray: objectTypeArray
    policyName: policyName
    vaultName: vaultName
    dataSourceSetInfoArray: dataSourceSetInfoArray
    principalId: principalId
  }
}
