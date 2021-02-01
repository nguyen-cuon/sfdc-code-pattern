global class AccountScheduler implements Schedulable{

    global void execute(SchedulableContext context) {
        runBatch(Utils.IS_AFTER_INSERT);
        runBatch(Utils.IS_AFTER_UPDATE);
        runBatch(Utils.IS_AFTER_DELETE);
    }

    private String getQueryBuilderString(String type) {
        String query = 'SELECT Id, IsSynchronized__c, TriggerType__c ' +
        + 'FROM Account ' +
        + 'WHERE IsSynchronized__c = FALSE AND TriggerType__c = \'' + type + '\' ALL ROWS';
        system.debug('myquery:' + query);
        return query;
    }

    private void runBatch(String type) {
        String query_insert = getQueryBuilderString(type);
        AccountBatch b = new AccountBatch(query_insert, type);
        database.executebatch(b, Utils.BATCH_RECORDS_SCOPE);
    }
}

// global class AccountScheduler implements Schedulable{
//     global void execute(SchedulableContext context) {
//         AccountBatch b = new AccountBatch();
//         Database.executebatch(b, Utils.BATCH_RECORDS_SCOPE);
//     }
// }