/*
 * 株式会社CUON（クオン）
 * 作成日：1/2021
 * 作成者：Nguyen Minh Phuong
 * 所属　：ビジネスコンサルティング事業部兼プロジェクト開発部
 * 役職　：アカウントエンジニア
 */
public class Utils {    
    public final static String ACCOUNT_TRIGGER = 'AccountTriggerActived';
    public final static String OPPORTUNITY_TRIGGER = 'OpportunityTriggerActived';
    public final static String USER_TRIGGER = 'UserTriggerActived';

    public final static String ACCOUNT_ENDPOINT = 'account';
    public final static String OPPORTUNITY_ENDPOINT = 'opportunity';
    public final static String USER_ENDPOINT = 'user';

    public final static String USER_SOBJ = 'User';
    public final static String Account_SOBJ = 'Account';
    public final static String Opportunity_SOBJ = 'Opportunity';

    public static final String IS_AFTER_INSERT = 'INSERT';
    public static final String IS_AFTER_UPDATE = 'UPDATE';
    public static final String IS_AFTER_DELETE = 'DELETE';

    public final static Integer BATCH_RECORDS_SCOPE = 200;

    public final static String NAMED_CREDENTIALS_NAME = 'ApiGatewayAwsConnectionInfo';

    public static Boolean isActivedTrigger(String triggerName){
        List<TriggerInfoSetting__mdt> ts = [SELECT Active__c, DeveloperName, MasterLabel 
            FROM TriggerInfoSetting__mdt WHERE DeveloperName LIKE :triggerName LIMIT 1];
        return ts[0]?.Active__c;
    }

    public static ExternalConnectionInfoSettings__mdt getConnectionInfoMetadata(){
        ExternalConnectionInfoSettings__mdt connInfo = [SELECT Aws_API_Gateway_key__c, Slack_Webhook_URL__c, 
            DeveloperName, MasterLabel 
            FROM ExternalConnectionInfoSettings__mdt];
        return connInfo;
    }

    public static String getNamedCredentialsURL(String DeveloperName) {
        List<NamedCredential> ncs = [SELECT DeveloperName, Endpoint FROM NamedCredential WHERE DeveloperName LIKE :DeveloperName LIMIT 1];
        return (ncs.size() > 0) ? ncs[0]?.Endpoint : '';
    }

    public static void postMessageToSlack(String message, String webhookURL) {
        Map<String,Object> msg = new Map<String,Object>();
        msg.put('text', message);
        msg.put('mrkdwn', true);
        String body = JSON.serialize(msg);  

        HttpRequest req = new HttpRequest();
        req.setEndpoint(webhookURL);
        req.setMethod('POST');
        req.setBody(body);
        Http http = new Http();
        if(!Test.isRunningTest()) {
            HttpResponse res = http.send(req);
        }
    }

    public static HttpRequest getHttpRequest(String endpoint) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('X-API-KEY', getConnectionInfoMetadata()?.Aws_API_Gateway_key__c);
        request.setEndpoint('callout:' + NAMED_CREDENTIALS_NAME + '/' + endpoint);
        return request;
    }

    public static Wrapper.CustomHttpResponse sendRequestToExternal(HttpRequest request, Set<Id> ids, String eventType, String sObjType) {
        Http http = new Http();
        HttpResponse response;
        if(!Test.isRunningTest()) {
            response = http.send(request);
        } else {
            response = new HttpResponse();
        }
        system.debug('myresponse.getBody():'+response.getBody());
        String[] msgs = new List<String>();
        Boolean isSynced = false;
        try {
            Wrapper.ResponseResource wr = (Wrapper.ResponseResource)JSON.deserialize(response.getBody(), Wrapper.ResponseResource.class);
            if(!wr.success) {
                msgs.add('[ERROR]' + wr.message);
            } else {
                isSynced = true;
                msgs.add('[SUCCESSFULLY]' + wr.message);
            }  
        } catch (Exception ex) {
            msgs.add('[EXCEPTION CLIENT]' + ex.getMessage() + '\n[EXCEPTION SERVER]' + response.getBody());
        }
        if(msgs.size() > 0) {
            Utils.postMessageToSlack(String.join(msgs, '====='), Utils.getConnectionInfoMetadata()?.Slack_Webhook_URL__c);
        }

        Wrapper.CustomHttpResponse cres = new Wrapper.CustomHttpResponse();
        cres.httpResponse = response;
        cres.isSynced = isSynced;
        cres.ids = ids;
        if(sObjType == ACCOUNT_SOBJ) {
            cres.sObjs = updateSyncStatusAccount(ids, String.join(msgs, '====='), isSynced, eventType);
        } else if(sObjType == OPPORTUNITY_SOBJ) {
            cres.sObjs = updateSyncStatusOpportunity(ids, String.join(msgs, '====='), isSynced, eventType);
        } else if(sObjType == USER_SOBJ){
            cres.sObjs = updateSyncStatusUser(ids, String.join(msgs, '====='), isSynced, eventType);
        }        
        return cres;
    }

    private static List<Account> updateSyncStatusAccount(Set<Id> ids, String message, Boolean isSuccess, String eventType) {
        List<Account> accs = new List<Account>();
        for(Account a: [SELECT Id, LatestSyncedDate__c, IsSynchronized__c, SyncMsg__c, TriggerType__c
                    FROM Account WHERE Id=:ids]) {
            a.LatestSyncedDate__c =  DateTime.now();
            a.IsSynchronized__c    = isSuccess;  
            a.SyncMsg__c = message;
            a.TriggerType__c = eventType; 
            accs.add(a);     
        }  
        // if(!Test.isRunningTest()) {
            update accs;   
        // }
        return accs;
    }

    private static List<Opportunity> updateSyncStatusOpportunity(Set<Id> ids, String message, Boolean isSuccess, String eventType) {
        List<Opportunity> opps = new List<Opportunity>();
        for(Opportunity opp: [SELECT Id, LatestSyncedDate__c, IsSynchronized__c, SyncMsg__c, TriggerType__c
                    FROM Opportunity WHERE Id=:ids]) {
            opp.LatestSyncedDate__c =  DateTime.now();
            opp.IsSynchronized__c = isSuccess;  
            opp.SyncMsg__c = message;
            opp.TriggerType__c = eventType; 
            opps.add(opp);     
        }  
        // if(!Test.isRunningTest()) {
            update opps;   
        // }
        return opps;
    }

    private static List<User> updateSyncStatusUser(Set<Id> ids, String message, Boolean isSuccess, String eventType) {
        List<User> us = new List<User>();
        for(User u: [SELECT Id, LatestSyncedDate__c, IsSynchronized__c, SyncMsg__c, TriggerType__c
                    FROM User WHERE Id=:ids]) {
            u.LatestSyncedDate__c =  DateTime.now();
            u.IsSynchronized__c    = isSuccess;  
            u.SyncMsg__c = message;
            u.TriggerType__c = eventType; 
            us.add(u);     
        }  
        // if(!Test.isRunningTest()) {
            update us;   
        // }
        return us;
    }

    public static void abortAllJobs() {
        List<CronTrigger> listCronTrigger = [SELECT Id, CronExpression, EndTime, NextFireTime, OwnerId,
                                            PreviousFireTime, StartTime, State, TimesTriggered, TimeZoneSidKey 
                                            FROM CronTrigger 
                                            WHERE State = 'Waiting' or State='Running'];
        System.debug('No of jobs: '+listCronTrigger.size());
        If (listCronTrigger.size() > 0)
        {
            for (Integer i = 0; i < listCronTrigger.size(); i++)
            { 
                System.abortJob(listCronTrigger[i].Id);
                System.debug('Job details ::'+String.valueOf(listCronTrigger[i]));
            }
        }
    }
}