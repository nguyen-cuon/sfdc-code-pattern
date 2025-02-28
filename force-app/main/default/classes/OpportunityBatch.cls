global class OpportunityBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    private String query;
    private String type;

    global OpportunityBatch(String soql, String triggerType) {
        query = soql;
        type = triggerType;
    }

    global Database.Querylocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<sObject> scop) {
        if(scop.size() > 0) {
            List<Opportunity> opps = (List<Opportunity>)scop;
            Set<Id> ids = new Set<id>();
            for(Opportunity opp: opps) {
                ids.add(opp.Id);
            }
            if(ids.size() > 0) {
                if(type == Utils.IS_AFTER_INSERT) {
                    OpportunityHandler.doCalloutToInsertOpportunity(ids);
                } else if(type == Utils.IS_AFTER_UPDATE) {
                    OpportunityHandler.doCalloutToUpdateOpportunity(ids);
                } else if(type == Utils.IS_AFTER_DELETE) {
                    OpportunityHandler.doCalloutToDeleteOpportunity(ids);
                }
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id =: bc.getJobId()];
        system.debug(job.Status);
    }
}