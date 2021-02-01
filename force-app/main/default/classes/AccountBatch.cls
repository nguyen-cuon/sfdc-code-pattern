global class AccountBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    private String query;
    private String type;

    global AccountBatch(String soql, String triggerType) {
        query = soql;
        type = triggerType;
    }

    global Database.Querylocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<sObject> scop) {
        if(scop.size() > 0) {
            List<Account> accs = (List<Account>)scop;
            Set<Id> ids = new Set<id>();
            for(Account acc: accs) {
                ids.add(acc.Id);
            }
            if(ids.size() > 0) {
                if(type == Utils.IS_AFTER_INSERT) {
                    AccountHandler.doCalloutToInsertAccount(ids);
                } else if(type == Utils.IS_AFTER_UPDATE) {
                    AccountHandler.doCalloutToUpdateAccount(ids);
                } else if(type == Utils.IS_AFTER_DELETE) {
                    AccountHandler.doCalloutToDeleteAccount(ids);
                }
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id =: bc.getJobId()];
        system.debug(job.Status);
    }
}

// global class AccountBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

//     public AccountBatch() {}
    
//     global Database.Querylocator start(Database.BatchableContext bc) {
//         String query = 'SELECT Id, IsSynchronized__c, TriggerType__c FROM Account WHERE TriggerType__c != NULL AND IsSynchronized__c = false ALL ROWS';
//         return Database.getQueryLocator(query);
//     }

//     global void execute(Database.BatchableContext bc, List<sObject> scop) {
//         if(scop.size() > 0) {
//             List<Account> accs = (List<Account>)scop;
//             Set<Id> insert_ids = new Set<id>();
//             Set<Id> update_ids = new Set<id>();
//             Set<Id> delete_ids = new Set<id>();
//             for(Account acc: accs) {
//                 if(acc.TriggerType__c.equals(Utils.IS_AFTER_INSERT)) {
//                     insert_ids.add(acc.Id);
//                 } else if(acc.TriggerType__c.equals(Utils.IS_AFTER_UPDATE)) {
//                     update_ids.add(acc.Id);
//                 } else if(acc.TriggerType__c.equals(Utils.IS_AFTER_DELETE)) {
//                     delete_ids.add(acc.Id);
//                 }
//             }

//             if(insert_ids.size() > 0) {
//                 AccountHandler.doCalloutToInsertAccount(insert_ids);
//             } 
//             if(update_ids.size() > 0) {
//                 AccountHandler.doCalloutToUpdateAccount(update_ids);
//             }
//             if(delete_ids.size() > 0) {
//                 AccountHandler.doCalloutToDeleteAccount(delete_ids);
//             }
//         }
//     }

//     global void finish(Database.BatchableContext bc) {
//         AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id =: bc.getJobId()];
//         system.debug(job.Status);
//     }
// }