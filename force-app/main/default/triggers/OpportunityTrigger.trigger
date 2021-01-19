trigger OpportunityTrigger on Opportunity (after insert, after update, after delete) {
    Set<Id> ids = new Set<Id>();
    Boolean isActivedTrigger = Utils.isActivedTrigger(Utils.OPPORTUNITY_TRIGGER);
    Boolean isStarted = OpportunityHandler.isStarted;
    
    if(isActivedTrigger && !isStarted) {
        if(trigger.isInsert) {
            OpportunityHandler.insertExternalOpportunity(trigger.newMap.keySet());
        } else if(trigger.isUpdate) {
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
            OpportunityHandler.deleteExternalOpportunity(trigger.newMap.keySet());
        }    
    }
}