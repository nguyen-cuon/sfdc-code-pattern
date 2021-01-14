/*
 * 株式会社CUON（クオン）
 * 作成日：2021/1/13
 * 作成者：Nguyen Minh Phuong
 * 所属　：ビジネスコンサルティング事業部兼プロジェクト開発部
 * 役職　：アカウントエンジニア
 */
public class Utils {    
    public final static String ACCOUNT_TRIGGER = 'AccountTriggerActived';
    public final static String OPPORTUNITY_TRIGGER = 'OpportunityTriggerActived';
    public final static String USER_TRIGGER = 'UserTriggerActived';

    
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
}