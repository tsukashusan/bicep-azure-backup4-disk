param vaultName string
param policielist array

resource diskbackuppolicie 'Microsoft.DataProtection/backupVaults/backupPolicies@2021-02-01-preview' = [for policy in policielist: {
  name:'${vaultName}/${policy}'
  properties:{
    objectType:'BackupPolicy'
    datasourceTypes:[
      'Microsoft.Compute/disks'
    ]
    policyRules:[
      {
        name: 'BackupHourly'
        objectType:'AzureBackupRule'
        backupParameters:{
          objectType:'AzureBackupParams'
          backupType: 'Incremental'
        }
        trigger:{
          objectType:'ScheduleBasedTriggerContext'
          schedule:{
            repeatingTimeIntervals:[
              'R/2021-06-02T02:51:10+00:00/PT4H'
            ]
          }
          taggingCriteria:[
            {
              tagInfo:{
                tagName:'Default'
              }
              taggingPriority:99
              isDefault: true
            }
          ]
        }
        dataStore:{
          dataStoreType:'OperationalStore'
          objectType:'DataStoreInfoBase'
        }
      }
      {
        objectType:'AzureRetentionRule'
        name: 'Default'
        isDefault: true
        lifecycles: [
          {
            deleteAfter:{
              objectType: 'AbsoluteDeleteOption'
              duration: 'P7D'
            }
            targetDataStoreCopySettings:[
              
            ]
            sourceDataStore:{
              dataStoreType:'OperationalStore'
              objectType: 'DataStoreInfoBase'
            }
          }
        ]
      }
    ]
  }
   
}]
