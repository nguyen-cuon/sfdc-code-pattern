global with sharing class OpportunityScheduler implements Schedulable{

    global void execute(SchedulableContext context) {
        runBatch(Utils.IS_AFTER_INSERT);
        runBatch(Utils.IS_AFTER_UPDATE);
        runBatch(Utils.IS_AFTER_DELETE);
    }

    private String getQueryBuilderString(String type) {
        String query = 'SELECT Id, IsSynchronized__c, TriggerType__c ' +
        + 'FROM Opportunity ' +
        + 'WHERE IsSynchronized__c = FALSE AND TriggerType__c = \'' + type + '\'';
        system.debug('myquery:' + query);
        return query;
    }

    private void runBatch(String type) {
        String query_insert = getQueryBuilderString(type);
        OpportunityBatch b = new OpportunityBatch(query_insert, type);
        database.executebatch(b, Utils.BATCH_RECORDS_SCOPE);
    }
}