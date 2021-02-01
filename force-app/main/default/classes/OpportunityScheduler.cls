/* 株式会社CUON（クオン）
 * 作成日：1/2021
 * 作成者：Nguyen Minh Phuong
 * 所属　：ビジネスコンサルティング事業部兼プロジェクト開発部
 * 役職　：アカウントエンジニア  */

global class OpportunityScheduler implements Schedulable{

    global void execute(SchedulableContext context) {
        runBatch(Utils.IS_AFTER_INSERT);
        runBatch(Utils.IS_AFTER_UPDATE);
        runBatch(Utils.IS_AFTER_DELETE);
    }

    private String getQueryBuilderString(String type) {
        String query = 'SELECT Id, IsSynchronized__c, TriggerType__c ' +
        + 'FROM Opportunity ' +
        + 'WHERE IsSynchronized__c = FALSE AND TriggerType__c = \'' + type + '\' ALL ROWS';
        system.debug('myquery:' + query);
        return query;
    }

    private void runBatch(String type) {
        String query_insert = getQueryBuilderString(type);
        OpportunityBatch b = new OpportunityBatch(query_insert, type);
        database.executebatch(b, Utils.BATCH_RECORDS_SCOPE);
    }
}