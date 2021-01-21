@isTest
private class AccountTestClass {
    @TestSetup
    private static void setupDataTest(){
        List<Account> acs = new List<Account>();
        Account ac = new Account();
        ac.Name = '株式会社ア';
        ac.Type = 'Prospect';
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
        for(Account acc: [SELECT Id, IsSynchronized__c, TriggerType__c, LatestSyncedDate__c, SyncMsg__c FROM Account WHERE Id=:(new Map<Id, Account>(acs)).keySet()]) {
            System.assertEquals(true, acc.IsSynchronized__c);
            System.assertEquals(Utils.IS_AFTER_INSERT, acc.TriggerType__c);
        }
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
        for(Account acc: [SELECT Id, IsSynchronized__c, TriggerType__c, LatestSyncedDate__c, SyncMsg__c FROM Account WHERE Id=:(new Map<Id, Account>(acs)).keySet()]) {
            System.assertEquals(true, acc.IsSynchronized__c);
            System.assertEquals(Utils.IS_AFTER_INSERT, acc.TriggerType__c);
        }
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
        for(Account acc: [SELECT Id, IsSynchronized__c, TriggerType__c, LatestSyncedDate__c, SyncMsg__c FROM Account WHERE Id=:(new Map<Id, Account>(acs)).keySet()]) {
            System.assertEquals(true, acc.IsSynchronized__c);
            System.assertEquals(Utils.IS_AFTER_INSERT, acc.TriggerType__c);
        }
    }

    @isTest
    private static void testDeleteAccount() {
        List<Account> acs = [SELECT Id, Name, Type FROM Account WHERE Name LIKE '株式会社ア'];
        if(acs.size() > 0) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, getFakeReponse(MockHttpResponseGenerator.DELETE_METHOD));
            delete acs;
            Test.stopTest();
            List<Account> newAcs = [SELECT Id, Name, Type FROM Account WHERE Name LIKE '株式会社ア'];
            System.assertEquals(0, newAcs.Size());
        }
    }

    private static MockHttpResponseGenerator getFakeReponse(String reqMethod) {
        String endpoint = 'callout:' + Utils.NAMED_CREDENTIALS_NAME + '/' + Utils.ACCOUNT_ENDPOINT;
        Integer code = 200; 
        String status = 'OK';
        String body = '{ "success": true, "message":"Handle user successfully!", "code":200 }';
        Map<String, String> responseHeaders = new Map<String, String>();
        responseHeaders.put('Content-Type', 'application/json');
        MockHttpResponseGenerator fakeResponse = new MockHttpResponseGenerator(code, status, body, responseHeaders, endpoint, reqMethod);
        return fakeResponse;
    }
}