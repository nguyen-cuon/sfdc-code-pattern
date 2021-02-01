/*
 * Created on Thu Aug 06 2020
 *
 * Copyright (c) 2020 nguyen@cuon.co.jp
 */
public with sharing class SalesReportTriggerHandler {
    public static void OnAfterInsert(List<SalesReport__c> newSalesReport) {
        // EXECUTE AFTER INSERT LOGIC
        List<Opportunity> oppList = new List<Opportunity>();
        for (SalesReport__c sr : newSalesReport) {
            if (sr.RecordTypeId == System.Label.SR_ForecastSetting_HighVoltage
                || sr.RecordTypeId == System.Label.SR_ForecastSetting_LowVoltage) {
                Opportunity opp = new Opportunity();
                opp.Name = sr.Name;
                opp.CloseDate = sr.AggregationDate__c;
                opp.SalesStaff__c = sr.SalesRepresentative__c;
                opp.ForecastKW__c = sr.ForecastKW__c;
                opp.ForecastNumber__c = sr.ForecastNumber__c;
                opp.StageName = System.Label.SettingPhaseOpportunity;
                opp.SalesReportMappingId__c = sr.Id;
                opp.OwnerId = sr.OwnerId;
                if (sr.RecordTypeId == System.Label.SR_ForecastSetting_HighVoltage) {
                    opp.RecordTypeId = System.Label.Op_ForecastSetting_HighVoltage;        
                } else if (sr.RecordTypeId == System.Label.SR_ForecastSetting_LowVoltage) {
                    opp.RecordTypeId = System.Label.Op_ForecastSetting_LowVoltage; 
                }
                oppList.add(opp);
            }
        }
        insert oppList;
    }

    public static void OnAfterUpdate(List<SalesReport__c> newSalesReport) {
        // EXECUTE AFTER UPDATE LOGIC
        List<Opportunity> oppUpdateList = new List<Opportunity>();
        for (SalesReport__c sr : newSalesReport) {
            if (sr.RecordTypeId == System.Label.SR_ForecastSetting_HighVoltage
                || sr.RecordTypeId == System.Label.SR_ForecastSetting_LowVoltage) {
                List<Opportunity> oppSalesList = [SELECT Id, Name, CloseDate, SalesStaff__c, 
                                                    ForecastKW__c, ForecastNumber__c, StageName, 
                                                    SalesReportMappingId__c, OwnerId
                                                    FROM Opportunity 
                                                    WHERE SalesReportMappingId__c =: sr.Id];
                for (Opportunity opp : oppSalesList) {
                    opp.Name = sr.Name;
                    opp.CloseDate = sr.AggregationDate__c;
                    opp.SalesStaff__c = sr.SalesRepresentative__c;
                    opp.ForecastKW__c = sr.ForecastKW__c;
                    opp.ForecastNumber__c = sr.ForecastNumber__c;
                    opp.OwnerId = sr.OwnerId;
                    if (sr.RecordTypeId == System.Label.SR_ForecastSetting_HighVoltage) {
                        opp.RecordTypeId = System.Label.Op_ForecastSetting_HighVoltage;        
                    } else if (sr.RecordTypeId == System.Label.SR_ForecastSetting_LowVoltage) {
                        opp.RecordTypeId = System.Label.Op_ForecastSetting_LowVoltage; 
                    }
                    oppUpdateList.add(opp);
                }
            }
        }
        update oppUpdateList;        
    }
}