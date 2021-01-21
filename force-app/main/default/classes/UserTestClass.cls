@isTest
private class UserTestClass {
    @TestSetup
    private static void setupDataTest(){
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
        Test.setMock(HttpCalloutMock.class, getFakeReponse(MockHttpResponseGenerator.POST_METHOD));
        insert us;
    }

    @isTest
    private static void testInsertUser() {
        List<User> us = new List<User>();
        User u1 = new User();
        u1.Username = 'hihonbashi.tarou@test.co.jp';
        u1.LastName = 'nihonbashi';
        u1.Email = 'hihonbashi.tarou@test.co.jp';
        u1.IsActive = true;
        u1.Alias ='Tokyo';
        u1.TimeZoneSidKey = 'Asia/Tokyo';
        u1.LocaleSidKey = 'ja_JP';
        u1.EmailEncodingKey = 'ISO-2022-JP';
        u1.LanguageLocaleKey = 'ja';

        Profile p = [SELECT Id, Name, UserLicenseId FROM Profile WHERE Name LIKE 'System Administrator' OR Name LIKE 'システム管理者' LIMIT 1];
        u1.ProfileId = p?.Id;

        us.add(u1);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, getFakeReponse(MockHttpResponseGenerator.POST_METHOD));
        insert us;
        Test.stopTest();
        for(User uc: [SELECT Id, IsSynchronized__c, TriggerType__c, LatestSyncedDate__c, SyncMsg__c FROM User WHERE Id=:(new Map<Id, User>(us)).keySet()]) {
            System.assertEquals(true, uc.IsSynchronized__c);
            System.assertEquals(Utils.IS_AFTER_INSERT, uc.TriggerType__c);
        }
    }

    @isTest
    private static void testUpdateUser() {
        List<User> us = new List<User>();
        for(User u: [SELECT Id, Username, LastName, Email FROM User WHERE Username = 'tokyo.tarou@test.co.jp']) {
            u.LastName = 'toukyo';
            us.add(u);
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, getFakeReponse(MockHttpResponseGenerator.PATCH_METHOD));
        update us;
        Test.stopTest();
        for(User uc: [SELECT Id, IsSynchronized__c, TriggerType__c, LatestSyncedDate__c, SyncMsg__c FROM User WHERE Id=:(new Map<Id, User>(us)).keySet()]) {
            System.assertEquals(true, uc.IsSynchronized__c);
            System.assertEquals(Utils.IS_AFTER_INSERT, uc.TriggerType__c);
        }
    }

    @isTest
    private static void testDeactiveUser() {
        List<User> us = new List<User>();
        for(User u: [SELECT Id, Username, LastName, Email, IsActive FROM User WHERE Username = 'tokyo.tarou@test.co.jp']) {
            u.IsActive = false;
            us.add(u);
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, getFakeReponse(MockHttpResponseGenerator.PATCH_METHOD));
        update us;
        Test.stopTest();
        for(User uc: [SELECT Id, IsSynchronized__c, TriggerType__c, LatestSyncedDate__c, SyncMsg__c FROM User WHERE Id=:(new Map<Id, User>(us)).keySet()]) {
            System.assertEquals(true, uc.IsSynchronized__c);
            System.assertEquals(Utils.IS_AFTER_INSERT, uc.TriggerType__c);
        }
    }

    private static MockHttpResponseGenerator getFakeReponse(String reqMethod) {
        String endpoint = 'callout:' + Utils.NAMED_CREDENTIALS_NAME + '/' + Utils.User_ENDPOINT;
        Integer code = 200; 
        String status = 'OK';
        String body = '{ "success": true, "message":"Handle user successfully!", "code":200 }';
        Map<String, String> responseHeaders = new Map<String, String>();
        responseHeaders.put('Content-Type', 'application/json');
        MockHttpResponseGenerator fakeResponse = new MockHttpResponseGenerator(code, status, body, responseHeaders, endpoint, reqMethod);
        return fakeResponse;
    }
}