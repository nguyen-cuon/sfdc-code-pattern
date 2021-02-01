@isTest
private class UtilsTestClass {
    @TestSetup
    private static void setupDataTest(){ }

    @isTest
    private static void testSendRequestAccount() {
        List<Account> acs = new List<Account>();
        Account ac = new Account();
        ac.Name = '株式会社ア';
        ac.Type = 'Prospect';
        acs.add(ac);
        Test.setMock(HttpCalloutMock.class, AccountTestClass.getFakeReponse(MockHttpResponseGenerator.POST_METHOD));
        insert acs;
        
        HttpRequest request = Utils.getHttpRequest(Utils.ACCOUNT_ENDPOINT);
        request.setMethod('POST');
        request.setBody('{ "accounts": ["account_id":"0016D00000RASLuQAP","account_name":"株式会社ア","account_type":"Prospect" }]');
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, Name, Type FROM Account WHERE Name LIKE '株式会社ア']);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, AccountTestClass.getFakeReponse(MockHttpResponseGenerator.POST_METHOD));
        Utils.sendRequestToExternal(request, accMap.keySet(), Utils.IS_AFTER_INSERT, Utils.Account_SOBJ);
        Test.stopTest();
    }

    @isTest
    private static void testSendRequestOpportunity() {
        List<Opportunity> opps = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = '案件ア';
        opp.Type = '新規';
        opp.StageName = 'Prospect';
        opp.CloseDate = Date.valueOf('2021-01-26');
        opps.add(opp);
        Test.setMock(HttpCalloutMock.class, OpportunityTestClass.getFakeReponse(MockHttpResponseGenerator.POST_METHOD));
        insert opps;

        HttpRequest request = Utils.getHttpRequest(Utils.OPPORTUNITY_ENDPOINT);
        request.setMethod('POST');
        request.setBody('{ "opportunities": ["opp_id":"0016D00000RASLuQAP","opp_name":"案件ア","opp_type":"新規","opp_stageName":"Proposal","opp_closeDate":"2021/01/26" }]');
        Map<Id, Opportunity> accMap = new Map<Id, Opportunity>([SELECT Id, Name, Type, StageName, CloseDate FROM Opportunity WHERE Name LIKE '案件ア']);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, OpportunityTestClass.getFakeReponse(MockHttpResponseGenerator.POST_METHOD));
        Utils.sendRequestToExternal(request, accMap.keySet(), Utils.IS_AFTER_INSERT, Utils.OPPORTUNITY_SOBJ);
        Test.stopTest();
    }

    @isTest
    private static void testSendRequestUser() {
        List<User> us = new List<User>();
        User u = new User();
        u.Username = 'tokyo.tarou@test.co.jp';
        u.LastName = 'tokyo';
        u.Email = 'tokyo.tarou@test.co.jp';
        u.IsActive = true;
        u.Alias ='Tokyo';
        u.TimeZoneSidKey = 'Asia/Tokyo';
        u.LocaleSidKey = 'ja_JP';
        u.EmailEncodingKey = 'ISO-2022-JP';
        u.LanguageLocaleKey = 'ja';

        Profile p = [SELECT Id, Name, UserLicenseId FROM Profile WHERE Name LIKE 'System Administrator' OR Name LIKE 'システム管理者' LIMIT 1];
        u.ProfileId = p?.Id;

        us.add(u);
        Test.setMock(HttpCalloutMock.class, UserTestClass.getFakeReponse(MockHttpResponseGenerator.POST_METHOD));
        insert us;

        HttpRequest request = Utils.getHttpRequest(Utils.USER_ENDPOINT);
        request.setMethod('POST');
        request.setBody('{ "users": ["user_id":"0016D11111RASLuQAP"]');
        Map<Id, User> accMap = new Map<Id, User>([SELECT Id, Username, LastName, Email, IsActive FROM User WHERE Username = 'tokyo.tarou@test.co.jp']);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, UserTestClass.getFakeReponse(MockHttpResponseGenerator.POST_METHOD));
        Utils.sendRequestToExternal(request, accMap.keySet(), Utils.IS_AFTER_INSERT, Utils.USER_SOBJ);
        Test.stopTest();
    }

    @isTest
    private static void testAbortAllJobs() {
        AccountScheduler sch = new AccountScheduler();
        // sch.execute(null);
        String cron = '20 30 8 10 2 ?';
        String jobID = system.schedule('My Job test', cron, sch);
        Test.startTest();
        Utils.abortAllJobs();
        Test.stopTest();
    }

    @isTest 
    private static void testNamedCredentialsURL() {
        Test.startTest();
        Utils.getNamedCredentialsURL('ApiGatewayAwsConnectionInfo');
        Test.stopTest();
    }

    @isTest
    private static void testSlackPostMsg() {
        Test.startTest();
        Utils.postMessageToSlack('成功', Utils.getConnectionInfoMetadata()?.Slack_Webhook_URL__c);
        Test.stopTest();
    }
}
