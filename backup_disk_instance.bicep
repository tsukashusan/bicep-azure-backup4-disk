param vaultName string
param backupInstanceNameArray array
param objectTypeArray array
param dataSourceInfoArray array
param policyName string
param dataSourceSetInfoArray array
param targetResourceGroupName string

resource diskbackup 'Microsoft.DataProtection/backupVaults/backupInstances@2021-02-01-preview' = [for (backupInstanceName, index) in backupInstanceNameArray: {
  name: '${vaultName}/${dataSourceInfoArray[index].resourceName}-${guid(backupInstanceName)}'
  properties: {
    friendlyName: dataSourceInfoArray[index].resourceName
    objectType: objectTypeArray[index]
    dataSourceInfo: {
      objectType: dataSourceInfoArray[index].objectType
      resourceID:  '${subscription().id}/resourceGroups/${targetResourceGroupName}/providers/${dataSourceInfoArray[index].resourceType}/${dataSourceInfoArray[index].resourceName}'
      resourceName: dataSourceInfoArray[index].resourceName
      resourceLocation: dataSourceInfoArray[index].resourceLocation
      resourceType: dataSourceInfoArray[index].resourceType
      resourceUri: '${subscription().id}/resourceGroups/${targetResourceGroupName}/providers/${dataSourceInfoArray[index].resourceType}/${dataSourceInfoArray[index].resourceName}'
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
