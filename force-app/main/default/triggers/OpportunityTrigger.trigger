/* 株式会社CUON（クオン）
 * 作成日：1/2021
 * 作成者：Nguyen Minh Phuong
 * 所属　：ビジネスコンサルティング事業部兼プロジェクト開発部
 * 役職　：アカウントエンジニア  */

trigger OpportunityTrigger on Opportunity (after insert, after update, after delete) {
    
    Boolean isActivedTrigger = Utils.isActivedTrigger(Utils.OPPORTUNITY_TRIGGER);
    Boolean isStarted = OpportunityHandler.isStarted;
    Boolean isAllowTrigger = OpportunityTestClass.shouldRunTrigger();
    
    if(isActivedTrigger && !isStarted && isAllowTrigger) {
        if(trigger.isInsert) {
            OpportunityHandler.insertExternalOpportunity(trigger.newMap.keySet());
        } else if(trigger.isUpdate) {
            Set<Id> ids = new Set<Id>();
            for(Opportunity acc: trigger.new) {
                if((trigger.oldMap.get(acc.Id).Name != acc.Name)
                    || (trigger.oldMap.get(acc.Id).Type != acc.Type)) {
                    ids.add(acc.Id);
                }
            }
            if(ids.size() > 0) {
                OpportunityHandler.updateExternalOpportunity(ids);
            }
        } else if(trigger.isDelete) {
            OpportunityHandler.deleteExternalOpportunity(trigger.oldMap.keySet());
        }    
    }
}