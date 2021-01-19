/*
 * 株式会社CUON（クオン）
 * 作成日：2021/1/13
 * 作成者：Nguyen Minh Phuong
 * 所属　：ビジネスコンサルティング事業部兼プロジェクト開発部
 * 役職　：アカウントエンジニア
 */
public with sharing class AccountHandler {
    //トリガ回帰を回避させるため
    public static Boolean isStarted = false;
    
    @future(callout=true)
    public static void insertExternalAccount(Set<Id> ids) {
        doCalloutToInsertAccount(ids);
    }

    @future(callout=true)
    public static void updateExternalAccount(Set<Id> ids) {
        doCalloutToUpdateAccount(ids);
    }

    @future(callout=true)
    public static void deleteExternalAccount(Set<Id> ids) {
        doCalloutToDeleteAccount(ids);
    }

    public static void doCalloutToInsertAccount(Set<Id> ids) {
        HttpRequest request = Utils.getHttpRequest(Utils.ACCOUNT_ENDPOINT);
        request.setMethod('POST');
        request.setBody(JSON.serialize(getMappingDataSyn(ids, false)));
        Wrapper.CustomHttpResponse wc = Utils.sendRequestToExternal(request, ids, Utils.IS_AFTER_INSERT, Utils.Account_SOBJ);
    }

    public static void doCalloutToUpdateAccount(Set<Id> ids) {
        HttpRequest request = Utils.getHttpRequest(Utils.ACCOUNT_ENDPOINT);
        request.setMethod('PATCH');
        request.setBody(JSON.serialize(getMappingDataSyn(ids, false)));
        Wrapper.CustomHttpResponse wc = Utils.sendRequestToExternal(request, ids, Utils.IS_AFTER_UPDATE, Utils.Account_SOBJ);
    }

    public static void doCalloutToDeleteAccount(Set<Id> ids) {
        HttpRequest request = Utils.getHttpRequest(Utils.ACCOUNT_ENDPOINT);
        request.setMethod('DELETE');
        request.setBody(JSON.serialize(getMappingDataSyn(ids, true)));
        Wrapper.CustomHttpResponse wc = Utils.sendRequestToExternal(request, ids, Utils.IS_AFTER_DELETE, Utils.Account_SOBJ);
    }

    private static List<Wrapper.Account> getMappingDataSyn(Set<Id> ids, Boolean isDelete) {
        List<Wrapper.Account> was = new List<Wrapper.Account>();
        for(Account acc: [SELECT Id, Name, Type, Phone FROM Account WHERE Id=:ids]) {
            Wrapper.Account wa = new Wrapper.Account();
            wa.account_id = acc.Id;
            if(!isDelete) {
                wa.account_name = acc.Name;
                wa.account_type = acc.Type;
                wa.account_phone = acc.Phone;
            }
            was.add(wa);
        }
        return was;
    }
}