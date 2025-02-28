/*
 * 株式会社CUON（クオン）
 * 作成日：1/2021
 * 作成者：Nguyen Minh Phuong
 * 所属　：ビジネスコンサルティング事業部兼プロジェクト開発部
 * 役職　：アカウントエンジニア
 */
trigger AccountTrigger on Account (after insert, after update, after delete) {
    
    Boolean isActivedTrigger = Utils.isActivedTrigger(Utils.ACCOUNT_TRIGGER);
    Boolean isStarted = AccountHandler.isStarted;
    Boolean isAllowTrigger = AccountTestClass.shouldRunTrigger();
    
    if(isActivedTrigger && !isStarted && isAllowTrigger) {
        if(trigger.isInsert) {
            AccountHandler.insertExternalAccount(trigger.newMap.keySet());
        } else if(trigger.isUpdate) {
            Set<Id> ids = new Set<Id>();
            for(Account acc: trigger.new) {
                if((trigger.oldMap.get(acc.Id).Name != acc.Name)
                    || (trigger.oldMap.get(acc.Id).Type != acc.Type)) {
                    ids.add(acc.Id);
                }
            }
            if(ids.size() > 0) {
                AccountHandler.updateExternalAccount(ids);
            }
        } else if(trigger.isDelete) {
            AccountHandler.deleteExternalAccount(trigger.oldMap.keySet());
        }    
    }
}