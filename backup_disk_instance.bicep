param vaultName string
param backupInstanceNameArray array
param objectTypeArray array
param dataSourceInfoArray array
param policyName string
param dataSourceSetInfoArray array
param principalId string

var DiskBackupReader = '3e5e47e6-65f7-47ef-90b5-e5dd4d455f24'
resource roleassign4 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' =[for dataSourceInfo in dataSourceInfoArray: {
  name: guid(resourceId('Microsoft.Compute/disks', dataSourceInfo.resourceName), dataSourceInfo.resourceName)
  properties: {
    principalId: principalId
    roleDefinitionId: '${resourceId('Microsoft.Compute/disks', dataSourceInfo.resourceName)}/providers/Microsoft.Authorization/roleDefinitions/${DiskBackupReader}'
  }
}]

resource diskbackup 'Microsoft.DataProtection/backupVaults/backupInstances@2021-02-01-preview' = [for (backupInstanceName, index) in backupInstanceNameArray: {
  name: '${vaultName}/${dataSourceInfoArray[index].resourceName}-${guid(backupInstanceName)}'
  properties: {
    friendlyName: dataSourceInfoArray[index].resourceName
    objectType: objectTypeArray[index]
    dataSourceInfo: {
      objectType: dataSourceInfoArray[index].objectType
      resourceID: resourceId(dataSourceInfoArray[index].resourceType, dataSourceInfoArray[index].resourceName)
      resourceName: dataSourceInfoArray[index].resourceName
      resourceLocation: dataSourceInfoArray[index].resourceLocation
      resourceType: dataSourceInfoArray[index].resourceType
      resourceUri: resourceId(dataSourceInfoArray[index].resourceType, dataSourceInfoArray[index].resourceName)
      datasourceType: dataSourceInfoArray[index].datasourceType
    }
    policyInfo: {
      policyId: '${resourceId('Microsoft.DataProtection/backupVaults', vaultName)}/backupPolicies/${policyName}'
      policyParameters: {
        dataStoreParametersList:[
          {
            objectType: 'AzureOperationalStoreParameters'
            dataStoreType:'OperationalStore'
            resourceGroupId: resourceGroup().id
          }
        ]
      }
    }
    dataSourceSetInfo: dataSourceSetInfoArray[index]
  }
  
}]
