/*
 * 株式会社CUON（クオン）
 * 作成日：2021/1/19
 * 作成者：Nguyen Minh Phuong
 * 所属　：ビジネスコンサルティング事業部兼プロジェクト開発部
 * 役職　：アカウントエンジニア
 */
public with sharing class UserHandler {
    //トリガ回帰を回避させるため
    public static Boolean isStarted = false;
    
    @future(callout=true)
    public static void insertExternalUser(Set<Id> ids) {
        doCalloutToInsertUser(ids);
    }

    @future(callout=true)
    public static void updateExternalUser(Set<Id> ids) {
        doCalloutToUpdateUser(ids);
    }

    @future(callout=true)
    public static void deleteExternalUser(Set<Id> ids) {
        doCalloutToDeleteUser(ids);
    }

    public static void doCalloutToInsertUser(Set<Id> ids) {
        HttpRequest request = Utils.getHttpRequest(Utils.USER_ENDPOINT);
        request.setMethod('POST');
        request.setBody(JSON.serialize(getMappingDataSyn(ids, false)));
        Wrapper.CustomHttpResponse wc = Utils.sendRequestToExternal(request, ids, Utils.IS_AFTER_INSERT, Utils.User_SOBJ);
    }

    public static void doCalloutToUpdateUser(Set<Id> ids) {
        HttpRequest request = Utils.getHttpRequest(Utils.USER_ENDPOINT);
        request.setMethod('PATCH');
        request.setBody(JSON.serialize(getMappingDataSyn(ids, false)));
        Wrapper.CustomHttpResponse wc = Utils.sendRequestToExternal(request, ids, Utils.IS_AFTER_UPDATE, Utils.User_SOBJ);
    }

    public static void doCalloutToDeleteUser(Set<Id> ids) {
        HttpRequest request = Utils.getHttpRequest(Utils.USER_ENDPOINT);
        request.setMethod('DELETE');
        request.setBody(JSON.serialize(getMappingDataSyn(ids, true)));
        Wrapper.CustomHttpResponse wc = Utils.sendRequestToExternal(request, ids, Utils.IS_AFTER_DELETE, Utils.User_SOBJ);
    }

    private static List<Wrapper.User> getMappingDataSyn(Set<Id> ids, Boolean isDelete) {
        List<Wrapper.User> wus = new List<Wrapper.User>();
        for(User u: [SELECT Id, UserName, LastName, Email FROM User WHERE Id=:ids]) {
            Wrapper.User wu = new Wrapper.User();
            wu.user_id = u.Id;
            if(!isDelete) {
                wu.user_username = u.UserName;
                wu.user_lastname = u.LastName;
                wu.user_email = u.Email;
            }
            wus.add(wu);
        }
        return wus;
    }
}