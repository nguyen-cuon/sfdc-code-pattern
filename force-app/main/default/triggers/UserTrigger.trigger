trigger UserTrigger on User (after insert, after update) {
    Boolean isActivedTrigger = Utils.isActivedTrigger(Utils.USER_TRIGGER);
    Boolean isStarted = UserHandler.isStarted;
    Boolean isAllowTrigger = OpportunityTestClass.shouldRunTrigger();
    
    if(isActivedTrigger && !isStarted && isAllowTrigger) {
        if(trigger.isInsert) {
            UserHandler.insertExternalUser(trigger.newMap.keySet());
        } else if(trigger.isUpdate) {
            Set<Id> ids = new Set<Id>();
            Set<Id> delIds = new Set<Id>();
            for(User acc: trigger.new) {
                if((trigger.oldMap.get(acc.Id).Username != acc.Username)
                    || (trigger.oldMap.get(acc.Id).LastName != acc.LastName)
                    || (trigger.oldMap.get(acc.Id).Email != acc.Email)
                    || (trigger.oldMap.get(acc.Id).IsActive != acc.IsActive)) {
                    if(acc.IsActive) {
                        ids.add(acc.Id);
                    } else {
                        delIds.add(acc.Id);
                    }
                }
            }
            if(ids.size() > 0) {
                UserHandler.updateExternalUser(ids);
            }
            if(delIds.size() > 0) {
                UserHandler.deleteExternalUser(ids);
            }
        } 
    }
}