@isTest
public class OpportunityTestClass {
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
        List<Opportunity> opps = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = '案件ア';
        opp.Type = '新規';
        opp.StageName = 'Proposal';
        opp.CloseDate = Date.today();
        opps.add(opp);
        Test.setMock(HttpCalloutMock.class, getFakeReponse(MockHttpResponseGenerator.POST_METHOD));
        insert opps;
    }

    @isTest
    private static void testInsertOpportunity() {
        List<Opportunity> opps = new List<Opportunity>();
        Opportunity opp1 = new Opportunity();
        opp1.Name = '案件イ';
        opp1.Type = '既存';
        opp1.StageName = 'Proposal';
        opp1.CloseDate = Date.today();
        opps.add(opp1);
        Test.setMock(HttpCalloutMock.class, getFakeReponse(MockHttpResponseGenerator.POST_METHOD));

        Test.startTest();
        insert opps;
        Test.stopTest();
    }

    @isTest
    private static void testUpdateNameOpportunity() {
        List<Opportunity> opps = new List<Opportunity>();
        for(Opportunity opp: [SELECT Id, Name, Type, StageName, CloseDate FROM Opportunity WHERE Name LIKE '案件ア']) {
            opp.Name = '案件A';
            opp.StageName = 'Proposal';
            opp.CloseDate = Date.today();
            opps.add(opp);
        }
        if(opps.size() > 0) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, getFakeReponse(MockHttpResponseGenerator.PATCH_METHOD));
            update opps;
            Test.stopTest();
        }
    }

    @isTest
    private static void testUpdateTypeOpportunity() {
        List<Opportunity> opps = new List<Opportunity>();
        for(Opportunity opp: [SELECT Id, Name, Type, StageName, CloseDate FROM Opportunity WHERE Name LIKE '案件ア']) {
            opp.Type = '既存';
            opp.StageName = 'Proposal';
            opp.CloseDate = Date.today();
            opps.add(opp);
        }
        if(opps.size() > 0) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, getFakeReponse(MockHttpResponseGenerator.PATCH_METHOD));
            update opps;
            Test.stopTest();
        }
    }

    @isTest
    private static void testDeleteOpportunity() {
        List<Opportunity> opps = [SELECT Id, Name, Type, StageName, CloseDate FROM Opportunity WHERE Name LIKE '案件ア'];
        if(opps.size() > 0) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, getFakeReponse(MockHttpResponseGenerator.DELETE_METHOD));
            delete opps;
            Test.stopTest();
        }
    }

    public static MockHttpResponseGenerator getFakeReponse(String reqMethod) {
        String endpoint = 'callout:' + Utils.NAMED_CREDENTIALS_NAME + '/' + Utils.OPPORTUNITY_ENDPOINT;
        Integer code = 200; 
        String status = 'OK';
        String body = '{ "success": true, "message":"Handle user successfully!", "code":200 }';
        Map<String, String> responseHeaders = new Map<String, String>();
        responseHeaders.put('Content-Type', 'application/json');
        MockHttpResponseGenerator fakeResponse = new MockHttpResponseGenerator(code, status, body, responseHeaders, endpoint, reqMethod);
        return fakeResponse;
    }

    @isTest
    private static void testOpportunityScheduler() {
        List<Opportunity> opps = new List<Opportunity>();
        Opportunity opp1 = new Opportunity();
        opp1.Name = '案件アスケジューラー1';
        opp1.Type = '新規';
        opp1.StageName = 'Proposal';
        opp1.CloseDate = Date.today();
        opp1.TriggerType__c = 'INSERT';
        opps.add(opp1);

        Opportunity opp2 = new Opportunity();
        opp2.Name = '案件アスケジューラー2';
        opp2.Type = '新規';
        opp2.StageName = 'Proposal';
        opp2.CloseDate = Date.today();
        opp2.TriggerType__c = 'UPDATE';
        opps.add(opp2);

        Opportunity opp3 = new Opportunity();
        opp3.Name = '案件アスケジューラー3';
        opp3.Type = '新規';
        opp3.StageName = 'Proposal';
        opp3.CloseDate = Date.today();
        opp3.TriggerType__c = 'DELETE';
        opps.add(opp3);

        setDisableRunTrigger();
        Test.setMock(HttpCalloutMock.class, getFakeReponse(MockHttpResponseGenerator.POST_METHOD));
        insert opps;

        OpportunityScheduler oppSch = new OpportunityScheduler();
        String cron = '20 30 8 10 2 ?';
        Test.startTest();
        String jobId = System.schedule('OpportunityScheduler', cron, oppSch);
        // oppSch.execute(null);
        Test.stopTest();
    }
}