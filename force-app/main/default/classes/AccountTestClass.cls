/* 株式会社CUON（クオン）
 * 作成日：1/2021
 * 作成者：Nguyen Minh Phuong
 * 所属　：ビジネスコンサルティング事業部兼プロジェクト開発部
 * 役職　：アカウントエンジニア  */

@isTest
public class AccountTestClass {

    //初期データ準備する際のトリガを無効にする目的
    private static Boolean isDisableRunTrigger = false;
    public static void setDisableRunTrigger() {
        isDisableRunTrigger = true;
    }
    public static Boolean shouldRunTrigger() {
        return !isDisableRunTrigger;
    }

    @TestSetup
    private static void setupDataTest(){
        setDisableRunTrigger();
        List<Account> acs = new List<Account>();
        Account ac = new Account();
        ac.Name = '株式会社ア';
        ac.Type = 'Prospect';
        ac.TriggerType__c = 'INSERT';
        ac.IsSynchronized__c = false;
        acs.add(ac);
        Test.setMock(HttpCalloutMock.class, getFakeReponse(MockHttpResponseGenerator.POST_METHOD));
        insert acs;
    }

    @isTest
    private static void testInsertAccount() {
        List<Account> acs = new List<Account>();
        Account ac1 = new Account();
        ac1.Name = '株式会社イ';
        ac1.Type = 'Investor';
        acs.add(ac1);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, getFakeReponse(MockHttpResponseGenerator.POST_METHOD));
        insert acs;
        Test.stopTest();
    }

    @isTest
    private static void testUpdateNameAccount() {
        List<Account> acs = new List<Account>();
        for(Account ac: [SELECT Id, Name, Type FROM Account WHERE Name LIKE '株式会社ア']) {
            ac.Name = '株式会社A';
            acs.add(ac);
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, getFakeReponse(MockHttpResponseGenerator.PATCH_METHOD));
        update acs;
        Test.stopTest();
    }

    @isTest
    private static void testUpdateTypeAccount() {
        List<Account> acs = new List<Account>();
        for(Account ac: [SELECT Id, Name, Type FROM Account WHERE Name LIKE '株式会社ア']) {
            ac.Type = 'Investor';
            acs.add(ac);
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, getFakeReponse(MockHttpResponseGenerator.PATCH_METHOD));
        update acs;
        Test.stopTest();
    }

    @isTest
    private static void testDeleteAccount() {
        List<Account> acs = [SELECT Id, Name, Type FROM Account WHERE Name LIKE '株式会社ア'];
        if(acs.size() > 0) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, getFakeReponse(MockHttpResponseGenerator.DELETE_METHOD));
            delete acs;
            Test.stopTest();
        }
    }

    public static MockHttpResponseGenerator getFakeReponse(String reqMethod) {
        String endpoint = 'callout:' + Utils.NAMED_CREDENTIALS_NAME + '/' + Utils.ACCOUNT_ENDPOINT;
        Integer code = 200; 
        String status = 'OK';
        String body = '{ "success": true, "message":"Handle user successfully!", "code":200 }';
        Map<String, String> responseHeaders = new Map<String, String>();
        responseHeaders.put('Content-Type', 'application/json');
        MockHttpResponseGenerator fakeResponse = new MockHttpResponseGenerator(code, status, body, responseHeaders, endpoint, reqMethod);
        return fakeResponse;
    }

    @isTest
    private static void testAccountScheduler() {
        List<Account> acs = new List<Account>();
        Account ac1 = new Account();
        ac1.Name = '株式会社アスケジューラー1';
        ac1.Type = 'Prospect';
        ac1.TriggerType__c = 'INSERT';
        acs.add(ac1);

        Account ac2 = new Account();
        ac2.Name = '株式会社アスケジューラー2';
        ac2.Type = 'Prospect';
        ac2.TriggerType__c = 'UPDATE';
        acs.add(ac2);

        Account ac3 = new Account();
        ac3.Name = '株式会社アスケジューラー3';
        ac3.Type = 'Prospect';
        ac3.TriggerType__c = 'DELETE';
        acs.add(ac3);
        setDisableRunTrigger();
        Test.setMock(HttpCalloutMock.class, getFakeReponse(MockHttpResponseGenerator.POST_METHOD));
        insert acs;

        AccountScheduler acSch = new AccountScheduler();
        String cron = '20 30 8 10 2 ?';
        Test.startTest();
        String jobId = System.schedule('AccountScheduler', cron, acSch);
        // acSch.execute(null);
        Test.stopTest();
    }
}