# Bicep sample (Azure Disk Backup)

## Preparation
1. Install az cli  
https://docs.microsoft.com/ja-jp/cli/azure/install-azure-cli
1. bicep install
https://github.com/Azure/bicep/blob/main/docs/installing.md#windows-installer
1. Edit parameter File
- azuredeploy.backup.disk-vault.parameters.dev.json</br>
  - require
    - xxx -> (backupVaultName)
    - xxxx -> (Name of policy)
    - GeoRedundant -> Choose LocallyRedundant or GeoRedundant.
```
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "backupVaultName": {
        "value": "xxx"
        },
        "policielist": {
            "value": ["xxxx"]
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
### STEP 1 (PowerShell) ??? recommended
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

### STEP 1 (cmd.exe) ??? not recommended
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
### STEP 2 (PowerShell) ??? recommended
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
  -TemplateFile ${bicepFile} `
  -TemplateParameterFile ${parameterFile} `
  -Verbose
```


### STEP 2 (Azure CLI + PowerShell) ??? recommended
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
az deployment group create --resource-group ${resourceGroupName} --template-file ${bicepFile} --parameters ${parameterFile} --verbose
```

### STEP 2 (Azure CLI + cmd.exe) ??? not recommended
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
az deployment group create --resource-group %resourceGroupName% --template-file %bicepFile% --parameters %parameterFile% --verbose
```
### STEP 3 Role Assign ###
- xxx -> Resource Group Name for Target Disk
- xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -> Vault of Managed ID (from Managed ID section of azure portal in backup container).
- xxxx -> Disk Resource Name (Reference __azuredeploy.backup.disk-instance.parameters.dev.json__)

```
# role assign
$targetResourceGroupforDisk = "xxx"
$servicePrincipal  = Get-AzADServicePrincipal -ObjectId  "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$roleDefinitionBackUpReaderName = "Disk Backup Reader"
$targetDiskName = "xxxx"
$diskResourceType = "Microsoft.Compute/disks"
$resource = Get-AzResource -name $targetDiskName -ResourceType $diskResourceType -ResourceGroupName $targetResourceGroupforDisk
New-AzRoleAssignment -RoleDefinitionName $roleDefinitionBackUpReaderName -Scope $resource.ResourceId -ApplicationId $servicePrincipal.ApplicationId

$roleDefinitionDiskSnapshotName = "Disk Snapshot Contributor"
$resourceGroup = Get-AzResourceGroup -ResourceGroupName $targetResourceGroupforDisk
New-AzRoleAssignment -RoleDefinitionName $roleDefinitionDiskSnapshotName -Scope $resourceGroup.ResourceId -ApplicationId $servicePrincipal.ApplicationId
```

## Usage(Set Backup Disk)
### STEP 1 (PowerShell) ??? recommended
1. Execute PowerShell Prompt
1. Set Parameter(x)

```
$bicepFile = "create_backup_disk.bicep"
$parameterFile = "azuredeploy.backup.disk-instance.parameters.dev.json"
```

### STEP 1 (cmd.exe) ??? not recommended
1. Execute PowerShell Prompt
1. Set Parameter(x)
```
setlocal
set bicepFile=create_backup_disk.bicep
set parameterFile=azuredeploy.backup.disk-instance.parameters.dev.json
```

2. Go to STEP2 (Azure CLI or PowerShell)

### STEP 2 (PowerShell) ??? recommended
1. Create Deployment
```
New-AzResourceGroupDeployment `
  -Name devenvironment `
  -ResourceGroupName ${resourceGroupName} `
  -TemplateFile ${bicepFile} `
  -TemplateParameterFile ${parameterFile} `
  -Verbose
```

### STEP 2 (Azure CLI + PowerShell) ??? recommended
1. Deployment Create  
```
az deployment group create --resource-group ${resourceGroupName} --template-file ${bicepFile} --parameters ${parameterFile} --verbose
```

### STEP 2 (Azure CLI + cmd.exe) ??? not recommended
1. Deployment Create  
```
az deployment group create --resource-group %resourceGroupName% --template-file %bicepFile% --parameters %parameterFile% --verbose
```

# CONFIDENTIAL 
????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
