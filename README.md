# Bicep sample (Azure Disk Backup)

## Preparation
1. Install az cli  
https://docs.microsoft.com/ja-jp/cli/azure/install-azure-cli
1. bicep install
https://github.com/Azure/bicep/blob/main/docs/installing.md#windows-installer
1. Edit parameter File
- azuredeploy.backup.disk-vault.parameters.dev.json</br>
  - require
    - xxxx -> (backupVaultName)
    - xxxxx -> (Name of policy)
    - LocallyRedundant -> Choose LocallyRedundant or GeoRedundant.
```
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "backupVaultName": {
        "value": "xxxx"
        },
        "policielist": {
            "value": ["xxxxx"]
        },
        "type": {
            "value": "LocallyRedundant"
        }
    }
}
```
- azuredeploy.backup.disk-instance.parameters.dev.json</br>
  - require
    - xx -> Backup Instance Name.
    - xxx -> Disk Resource Name.
    - xxxx -> Resource of location.
    - xxxxx -> Policy Name (Reference azuredeploy.backup.disk-vault.parameters.dev.json).
    - xxxxxx -> Vault Name (Reference azuredeploy.backup.disk-vault.parameters.dev.json).
    - xxxxxxx -> Resource Group Name (from target disk of ResourceGroup)
```
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "backupInstanceNameArray": {
            "value": ["xx"]
        },
        "dataSourceInfoArray": {
            "value": [
                {
                    "objectType": "Datasource",
                    "resourceName": "xxx",
                    "resourceType": "Microsoft.Compute/disks",
                    "resourceLocation": "xxxx",
                    "datasourceType": "Microsoft.Compute/disks"
                }
            ]
        },
        "objectTypeArray": {
            "value": ["BackupInstance"]
        },
        "dataSourceSetInfoArray":{
            "value": [null]
        },
        "policyName":{
            "value": "xxxxx"
        },
        "vaultName":{
            "value": "xxxxxx"
        },
        "targetResourceGroupName":{
            "value": "xxxxxxx"
        }
    }
}
```

## Usage(Create Container)
### STEP 1 (PowerShell) ※ recommended
1. Execute PowerShell Prompt
1. Set Parameter(x)

```
set-variable -name TENANT_ID "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" -option constant
set-variable -name SUBSCRIPTOIN_GUID "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" -option constant

$bicepFile = "create_disk_vault_policy.bicep"
$parameterFile = "azuredeploy.backup.disk-vault.parameters.dev.json"
$resourceGroupName = "xxxxx"
$location = "xxxxx"
```

### STEP 1 (cmd.exe) ※ not recommended
1. Execute PowerShell Prompt
1. Set Parameter(x)

```
setlocal
set TENANT_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
set SUBSCRIPTOIN_GUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
set bicepFile=create_disk_vault_policy.bicep
set parameterFile=azuredeploy.backup.disk-vault.parameters.dev.json
set resourceGroupName=xxxxx
set location=xxxxx
```

2. Go to STEP2 (Azure CLI or PowerShell)
### STEP 2 (PowerShell) ※ recommended
1. Azure Login
```
Connect-AzAccount -Tenant ${TENANT_ID} -Subscription ${SUBSCRIPTOIN_GUID}
```
2. Create Resource Group  
```
New-AzResourceGroup -Name ${resourceGroupName} -Location ${location} -Verbose
```
3. Create Deployment
```
New-AzResourceGroupDeployment `
  -Name devenvironment `
  -ResourceGroupName ${resourceGroupName} `
  -TemplateFile ${BICEP_FILE} `
  -TemplateParameterFile ${PARAMETER_FILE} `
  -Verbose
```


### STEP 2 (Azure CLI + PowerShell) ※ recommended
1. Azure Login
```
az login -t ${TENANT_ID} --verbose
```
2. Set Subscription
```
az account set --subscription ${SUBSCRIPTOIN_GUID} --verbose
```
3. Create Resource Group  
```
az group create --name ${resourceGroupName} --location ${location} --verbose
```
4. Deployment Create  
```
az deployment group create --resource-group ${resourceGroupName} --template-file ${BICEP_FILE} --parameters ${PARAMETER_FILE} --verbose
```

### STEP 2 (Azure CLI + cmd.exe) ※ not recommended
1. Azure Login
```
az login -t %TENANT_ID% --verbose
```
2. Set Subscription
```
az account set --subscription %SUBSCRIPTOIN_GUID% --verbose
```
3. Create Resource Group  
```
az group create --name %resourceGroupName% --location %location% --verbose
```
4. Deployment Create  
```
az deployment group create --resource-group %resourceGroupName% --template-file %BICEP_FILE% --parameters %PARAMETER_FILE% --verbose
```
### STEP 3 Role Assign ###
- xxx -> Vault Name (Reference __azuredeploy.backup.disk-vault.parameters.dev.json__).
- xxxx -> Disk Resource Name (Reference __azuredeploy.backup.disk-instance.parameters.dev.json__)

```
# role assign
$servicePrincipal = Get-AzADServicePrincipal -DisplayName "xxx"
$roleDefinitionBackUpReaderName = "Disk Backup Reader"
$targetDiskName = "xxxx"
$diskResourceType = "Microsoft.Compute/disks"
$resource = Get-AzResource -name $targetDiskName -ResourceType $diskResourceType -ResourceGroupName $resourceGroupName
New-AzRoleAssignment -RoleDefinitionName $roleDefinitionBackUpReaderName   -Scope $resource.ResourceId -ApplicationId $servicePrincipal.ApplicationId

$roleDefinitionDiskSnapshotName = "Disk Snapshot Contributor"

$resourceGroup = Get-AzResourceGroup -ResourceGroupName $resourceGroupName
New-AzRoleAssignment -RoleDefinitionName $roleDefinitionDiskSnapshotName  -Scope $resourceGroup.ResourceId -ApplicationId $servicePrincipal.ApplicationId
```
## Usage(Set Backup Disk)
### STEP 1 (PowerShell) ※ recommended
1. Execute PowerShell Prompt
1. Set Parameter(x)

```
$bicepFile = "create_backup_disk.bicep"
$parameterFile = "azuredeploy.backup.disk-instance.parameters.dev.json"
```

### STEP 1 (cmd.exe) ※ not recommended
1. Execute PowerShell Prompt
1. Set Parameter(x)
```
setlocal
set bicepFile=create_backup_disk.bicep
set parameterFile=azuredeploy.backup.disk-instance.parameters.dev.json
```

2. Go to STEP2 (Azure CLI or PowerShell)

### STEP 2 (PowerShell) ※ recommended
1. Create Deployment
```
New-AzResourceGroupDeployment `
  -Name devenvironment `
  -ResourceGroupName ${resourceGroupName} `
  -TemplateFile ${BICEP_FILE} `
  -TemplateParameterFile ${PARAMETER_FILE} `
  -Verbose
```

### STEP 2 (Azure CLI + PowerShell) ※ recommended
1. Deployment Create  
```
az deployment group create --resource-group ${resourceGroupName} --template-file ${BICEP_FILE} --parameters ${PARAMETER_FILE} --verbose
```

### STEP 2 (Azure CLI + cmd.exe) ※ not recommended
1. Deployment Create  
```
az deployment group create --resource-group %resourceGroupName% --template-file %bicepFile% --parameters %parameterFile% --verbose
```

# CONFIDENTIAL 
本リポジトリにあるすべての成果物は情報提供のみを目的としており、本リポジトリにあるすべての成果物に記載されている情報は、状況等の変化により、内容は変更される場合があります。本リポジトリにあるすべての成果物の情報に対して明示的、黙示的または法的な、いかなる保証も行いません。
