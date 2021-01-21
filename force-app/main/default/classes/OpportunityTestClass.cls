@isTest
private class OpportunityTestClass {
    // @TestSetup
    // private static void setupDataTest(){
    //     List<Opportunity> opps = new List<Opportunity>();
    //     Opportunity opp = new Opportunity();
    //     opp.Name = '案件ア';
    //     opp.Type = '新規';
    //     opp.StageName = 'Proposal';
    //     opp.CloseDate = Date.today();
    //     opps.add(opp);
    //     Test.setMock(HttpCalloutMock.class, getFakeReponse(MockHttpResponseGenerator.POST_METHOD));
    //     insert opps;
    // }

    @isTest
    private static void testInsertOpportunity() {
        List<Opportunity> opps = new List<Opportunity>();
        Opportunity opp1 = new Opportunity();
        opp1.Name = '案件イ';
        opp1.Type = '既存';
        opp1.StageName = 'Proposal';
        opp1.CloseDate = Date.today();
        opps.add(opp1);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, getFakeReponse(MockHttpResponseGenerator.POST_METHOD));
        insert opp1;
        Test.stopTest();
    }

    // @isTest
    // private static void testUpdateNameOpportunity() {
    //     List<Opportunity> opps = new List<Opportunity>();
    //     for(Opportunity opp: [SELECT Id, Name, Type, StageName, CloseDate FROM Opportunity WHERE Name LIKE '案件ア']) {
    //         opp.Name = '案件A';
    //         opp.StageName = 'Proposal';
    //         opp.CloseDate = Date.today();
    //         opps.add(opp);
    //     }
    //     Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, getFakeReponse(MockHttpResponseGenerator.PATCH_METHOD));
    //     update opps;
    //     Test.stopTest();
    // }

    // @isTest
    // private static void testUpdateTypeOpportunity() {
    //     List<Opportunity> opps = new List<Opportunity>();
    //     for(Opportunity opp: [SELECT Id, Name, Type, StageName, CloseDate FROM Opportunity WHERE Name LIKE '案件ア']) {
    //         opp.Type = '既存';
    //         opp.StageName = 'Proposal';
    //         opp.CloseDate = Date.today();
    //         opps.add(opp);
    //     }
    //     Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, getFakeReponse(MockHttpResponseGenerator.PATCH_METHOD));
    //     update opps;
    //     Test.stopTest();
    // }

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

    private static MockHttpResponseGenerator getFakeReponse(String reqMethod) {
        String endpoint = 'callout:' + Utils.NAMED_CREDENTIALS_NAME + '/' + Utils.OPPORTUNITY_ENDPOINT;
        Integer code = 200; 
        String status = 'OK';
        String body = '{ "success": true, "message":"Handle user successfully!", "code":200 }';
        Map<String, String> responseHeaders = new Map<String, String>();
        responseHeaders.put('Content-Type', 'application/json');
        MockHttpResponseGenerator fakeResponse = new MockHttpResponseGenerator(code, status, body, responseHeaders, endpoint, reqMethod);
        return fakeResponse;
    }
}