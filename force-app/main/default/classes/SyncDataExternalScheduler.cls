global class SyncDataExternalScheduler implements Schedulable{
    private final String SOBJ_TYPE_ACCOUNT = 'Account';
    private final String SOBJ_TYPE_OPPORTUNITY = 'Opportunity';
    private final String SOBJ_TYPE_USER = 'User';

    global void execute(SchedulableContext sc) {
        runAccountBatch(Utils.IS_AFTER_INSERT, SOBJ_TYPE_ACCOUNT);
        runAccountBatch(Utils.IS_AFTER_UPDATE, SOBJ_TYPE_ACCOUNT);
        runAccountBatch(Utils.IS_AFTER_DELETE, SOBJ_TYPE_ACCOUNT);

        runOpportunityBatch(Utils.IS_AFTER_INSERT, SOBJ_TYPE_OPPORTUNITY);
        runOpportunityBatch(Utils.IS_AFTER_UPDATE, SOBJ_TYPE_OPPORTUNITY);
        runOpportunityBatch(Utils.IS_AFTER_DELETE, SOBJ_TYPE_OPPORTUNITY);

        runUserBatch(Utils.IS_AFTER_INSERT, SOBJ_TYPE_USER);
        runUserBatch(Utils.IS_AFTER_UPDATE, SOBJ_TYPE_USER);
        runUserBatch(Utils.IS_AFTER_DELETE, SOBJ_TYPE_USER);
    }

    private String getQueryBuilderString(String type, String sObjName) {
        String query = 'SELECT Id, IsSynchronized__c, TriggerType__c FROM ' + sObjName + ' WHERE IsSynchronized__c = FALSE AND TriggerType__c = \'' + type + '\'';
        return query;
    }

    private void runAccountBatch(String type, String sObjName) {
        AccountBatch ab = new AccountBatch(getQueryBuilderString(type, sObjName), type);
        Database.executebatch(ab, Utils.BATCH_RECORDS_SCOPE);
    }
    
    private void runOpportunityBatch(String type, String sObjName) {
        AccountBatch ab = new AccountBatch(getQueryBuilderString(type, sObjName), type);
        Database.executebatch(ab, Utils.BATCH_RECORDS_SCOPE);
    }

    private void runUserBatch(String type, String sObjName) {
        AccountBatch ab = new AccountBatch(getQueryBuilderString(type, sObjName), type);
        Database.executebatch(ab, Utils.BATCH_RECORDS_SCOPE);
    }

}