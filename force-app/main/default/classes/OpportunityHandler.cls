/*
 * 株式会社CUON（クオン）
 * 作成日：2021/1/18
 * 作成者：Nguyen Minh Phuong
 * 所属　：ビジネスコンサルティング事業部兼プロジェクト開発部
 * 役職　：アカウントエンジニア
 */
public with sharing class OpportunityHandler {
    //トリガ回帰を回避させるため
    public static Boolean isStarted = false;
    
    @future(callout=true)
    public static void insertExternalOpportunity(Set<Id> ids) {
        doCalloutToInsertOpportunity(ids);
    }

    @future(callout=true)
    public static void updateExternalOpportunity(Set<Id> ids) {
        doCalloutToUpdateOpportunity(ids);
    }

    @future(callout=true)
    public static void deleteExternalOpportunity(Set<Id> ids) {
        doCalloutToDeleteOpportunity(ids);
    }

    public static void doCalloutToInsertOpportunity(Set<Id> ids) {
        HttpRequest request = Utils.getHttpRequest(Utils.OPPORTUNITY_ENDPOINT);
        request.setMethod('POST');
        request.setBody(JSON.serialize(getMappingDataSyn(ids, false)));
        Wrapper.CustomHttpResponse wc = Utils.sendRequestToExternal(request, ids, Utils.IS_AFTER_INSERT, Utils.OPPORTUNITY_SOBJ);
    }

    public static void doCalloutToUpdateOpportunity(Set<Id> ids) {
        HttpRequest request = Utils.getHttpRequest(Utils.OPPORTUNITY_ENDPOINT);
        request.setMethod('PATCH');
        request.setBody(JSON.serialize(getMappingDataSyn(ids, false)));
        Wrapper.CustomHttpResponse wc = Utils.sendRequestToExternal(request, ids, Utils.IS_AFTER_UPDATE, Utils.OPPORTUNITY_SOBJ);
    }

    public static void doCalloutToDeleteOpportunity(Set<Id> ids) {
        HttpRequest request = Utils.getHttpRequest(Utils.OPPORTUNITY_ENDPOINT);
        request.setMethod('DELETE');
        request.setBody(JSON.serialize(getMappingDataSyn(ids, true)));
        Wrapper.CustomHttpResponse wc = Utils.sendRequestToExternal(request, ids, Utils.IS_AFTER_DELETE, Utils.OPPORTUNITY_SOBJ);
    }

    private static List<Wrapper.Opportunity> getMappingDataSyn(Set<Id> ids, Boolean isDelete) {
        isStarted = true;
        List<Wrapper.Opportunity> wos = new List<Wrapper.Opportunity>();
        for(Opportunity opp: [SELECT Id, Name, Type, StageName, CloseDate FROM Opportunity WHERE Id=:ids]) {
            Wrapper.Opportunity wo = new Wrapper.Opportunity();
            wo.opp_id = opp.Id;
            if(!isDelete) {
                wo.opp_name = opp.Name;
                wo.opp_type = opp.Type;
                wo.opp_stageName = opp.StageName;
                wo.opp_closeDate = opp.CloseDate;
            }
            wos.add(wo);
        }
        return wos;
    }
}