/*
 * Created on Thu Aug 06 2020
 *
 * Copyright (c) 2020 nguyen@cuon.co.jp
 */

trigger SalesReportTrigger on SalesReport__c (after insert, after update) {
    if (trigger.isAfter) {
        if(trigger.isInsert) {
            SalesReportTriggerHandler.OnAfterInsert(trigger.new);
        } else if(trigger.isUpdate) {
            SalesReportTriggerHandler.OnAfterUpdate(trigger.new);
        }
    }
}