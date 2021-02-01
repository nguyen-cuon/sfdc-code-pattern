/* 株式会社CUON（クオン）
 * 作成日：1/2021
 * 作成者：Nguyen Minh Phuong
 * 所属　：ビジネスコンサルティング事業部兼プロジェクト開発部
 * 役職　：アカウントエンジニア  */

@isTest
public class UserTestClass {
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
        setDisableRunTrigger();
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
    }

    public static MockHttpResponseGenerator getFakeReponse(String reqMethod) {
        String endpoint = 'callout:' + Utils.NAMED_CREDENTIALS_NAME + '/' + Utils.User_ENDPOINT;
        Integer code = 200; 
        String status = 'OK';
        String body = '{ "success": true, "message":"Handle user successfully!", "code":200 }';
        Map<String, String> responseHeaders = new Map<String, String>();
        responseHeaders.put('Content-Type', 'application/json');
        MockHttpResponseGenerator fakeResponse = new MockHttpResponseGenerator(code, status, body, responseHeaders, endpoint, reqMethod);
        return fakeResponse;
    }

    @isTest
    private static void testMockResponse() {
        getFakeReponse(MockHttpResponseGenerator.POST_METHOD);
    }

    @isTest
    private static void testUserScheduler() {
        Profile p = [SELECT Id, Name, UserLicenseId FROM Profile WHERE Name LIKE 'System Administrator' OR Name LIKE 'システム管理者' LIMIT 1];

        List<User> us = new List<User>();
        User u1 = new User();
        u1.Username = 'tokyo1.tarou@test.co.jp';
        u1.LastName = 'tokyo1';
        u1.Email = 'tokyo1.tarou@test.co.jp';
        u1.IsActive = true;
        u1.Alias ='Tokyo';
        u1.TimeZoneSidKey = 'Asia/Tokyo';
        u1.LocaleSidKey = 'ja_JP';
        u1.EmailEncodingKey = 'ISO-2022-JP';
        u1.LanguageLocaleKey = 'ja';
        u1.ProfileId = p?.Id;
        u1.TriggerType__c = 'INSERT';
        us.add(u1);
        
        User u2 = new User();
        u2.Username = 'tokyo2.tarou@test.co.jp';
        u2.LastName = 'tokyo2';
        u2.Email = 'tokyo2.tarou@test.co.jp';
        u2.IsActive = true;
        u2.Alias ='Tokyo';
        u2.TimeZoneSidKey = 'Asia/Tokyo';
        u2.LocaleSidKey = 'ja_JP';
        u2.EmailEncodingKey = 'ISO-2022-JP';
        u2.LanguageLocaleKey = 'ja';
        u2.ProfileId = p?.Id;
        u2.TriggerType__c = 'UPDATE';
        us.add(u2);

        User u3 = new User();
        u3.Username = 'tokyo3.tarou@test.co.jp';
        u3.LastName = 'tokyo3';
        u3.Email = 'tokyo3.tarou@test.co.jp';
        u3.IsActive = true;
        u3.Alias ='Tokyo';
        u3.TimeZoneSidKey = 'Asia/Tokyo';
        u3.LocaleSidKey = 'ja_JP';
        u3.EmailEncodingKey = 'ISO-2022-JP';
        u3.LanguageLocaleKey = 'ja';
        u3.ProfileId = p?.Id;
        u3.TriggerType__c = 'DELETE';
        us.add(u3);

        setDisableRunTrigger();
        Test.setMock(HttpCalloutMock.class, getFakeReponse(MockHttpResponseGenerator.POST_METHOD));
        insert us;

        UserScheduler usSch = new UserScheduler();
        String cron = '20 30 8 10 2 ?';
        Test.startTest();
        String jobId = System.schedule('UserScheduler', cron, usSch);
        // usSch.execute(null);
        Test.stopTest();
    }
}