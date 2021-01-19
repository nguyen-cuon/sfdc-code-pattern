global class UserBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    private String query;
    private String type;

    global UserBatch(String soql, String triggerType) {
        query = soql;
        type = triggerType;
    }

    global Database.Querylocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<sObject> scop) {
        if(scop.size() > 0) {
            List<User> accs = (List<User>)scop;
            Set<Id> ids = new Set<id>();
            for(User acc: accs) {
                ids.add(acc.Id);
            }
            if(ids.size() > 0) {
                if(type == Utils.IS_AFTER_INSERT) {
                   UserHandler.doCalloutToInsertUser(ids);
                } else if(type == Utils.IS_AFTER_UPDATE) {
                   UserHandler.doCalloutToUpdateUser(ids);
                } else if(type == Utils.IS_AFTER_DELETE) {
                   UserHandler.doCalloutToDeleteUser(ids);
                }
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id =: bc.getJobId()];
        system.debug(job.Status);
    }
}