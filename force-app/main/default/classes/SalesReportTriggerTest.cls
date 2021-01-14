/*
 * Created on Thu Aug 06 2020
 *
 * Copyright (c) 2020 nguyen@cuon.co.jp
 */

@isTest
private class SalesReportTriggerTest {
    @TestSetup
    static void setupDataTest(){
        Profile profile = [SELECT Id,Name FROM Profile WHERE Name='システム管理者']; 
        User user = new User(Alias = 'amint', Email='amintest@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='アドミン試験', LanguageLocaleKey='ja', 
                            LocaleSidKey='ja_JP', ProfileId = profile.Id, 
                            TimeZoneSidKey='Asia/Tokyo', UserName='amintest@testorg.com');
        insert user;

        List<SalesReport__c> srList = new List<SalesReport__c>();
        SalesReport__c sr1 = new SalesReport__c();
        sr1.Name = 'セールスレポート試験名１';
        sr1.AggregationDate__c = Date.today();
        sr1.SalesRepresentative__c = user.Id;
        sr1.ForecastKW__c = 1000;
        sr1.ForecastNumber__c = 1;
        sr1.OwnerId = user.Id;
        sr1.RecordTypeId = System.Label.SR_ForecastSetting_HighVoltage;
        srList.add(sr1);

        SalesReport__c sr2 = new SalesReport__c();
        sr2.Name = 'セールスレポート試験名２';
        sr2.AggregationDate__c = Date.today();
        sr2.SalesRepresentative__c = user.Id;
        sr2.ForecastKW__c = 2000;
        sr2.ForecastNumber__c = 2;
        sr2.OwnerId = user.Id;
        sr2.RecordTypeId = System.Label.SR_ForecastSetting_LowVoltage;
        srList.add(sr2);

        insert srList;
    }

    @IsTest
    static void testOnAfterInsertHighVolMethod(){
        SalesReport__c sr = [SELECT Id, Name, AggregationDate__c, RecordTypeId, OwnerId,
                                        SalesRepresentative__c, ForecastKW__c, ForecastNumber__c
                                        FROM SalesReport__c
                                        WHERE Name LIKE 'セールスレポート試験名１'
                                        LIMIT 1];
        checkResultByRecordType(System.Label.Op_ForecastSetting_HighVoltage, sr);
    }

    @IsTest
    static void testOnAfterInsertLowVolMethod(){
        SalesReport__c sr = [SELECT Id, Name, AggregationDate__c, RecordTypeId, OwnerId,
                                        SalesRepresentative__c, ForecastKW__c, ForecastNumber__c
                                        FROM SalesReport__c
                                        WHERE Name LIKE 'セールスレポート試験名２'
                                        LIMIT 1];
        checkResultByRecordType(System.Label.Op_ForecastSetting_LowVoltage, sr);
    }

    @IsTest
    static void testOnAfterUpdateHighVolMethod(){
        SalesReport__c sr = [SELECT Id, Name, AggregationDate__c, RecordTypeId, OwnerId,
                                        SalesRepresentative__c, ForecastKW__c, ForecastNumber__c
                                        FROM SalesReport__c
                                        WHERE Name LIKE 'セールスレポート試験名１'
                                        LIMIT 1];
        sr.ForecastKW__c = 123;
        sr.ForecastNumber__c = 7;
        update sr;
        checkResultByRecordType(System.Label.Op_ForecastSetting_HighVoltage, sr);
    }

    @IsTest
    static void testOnAfterUpdateLowVolMethod(){
        SalesReport__c sr = [SELECT Id, Name, AggregationDate__c, RecordTypeId, OwnerId,
                                        SalesRepresentative__c, ForecastKW__c, ForecastNumber__c
                                        FROM SalesReport__c
                                        WHERE Name LIKE 'セールスレポート試験名２'
                                        LIMIT 1];
        sr.ForecastKW__c = 999;
        sr.ForecastNumber__c = 4;
        update sr;
        checkResultByRecordType(System.Label.Op_ForecastSetting_LowVoltage, sr);
    }

    private static void checkResultByRecordType(String recordTypeId, SalesReport__c sr) {
        List<Opportunity> oppList = [SELECT Id, Name, CloseDate, SalesStaff__c, ForecastKW__c, 
                                    ForecastNumber__c, StageName, SalesReportMappingId__c, OwnerId, RecordTypeId
                                    FROM Opportunity
                                    WHERE SalesReportMappingId__c =: sr.Id LIMIT 1];
        System.assert(oppList.size() > 0);
        Opportunity opp = oppList.get(0);
        System.assertEquals(opp.Name , sr.Name);
        System.assertEquals(opp.CloseDate , sr.AggregationDate__c);
        System.assertEquals(opp.SalesStaff__c , sr.SalesRepresentative__c);
        System.assertEquals(opp.ForecastKW__c , sr.ForecastKW__c);
        System.assertEquals(opp.ForecastNumber__c , sr.ForecastNumber__c);
        System.assertEquals(opp.StageName , System.Label.SettingPhaseOpportunity);
        System.assertEquals(opp.SalesReportMappingId__c , sr.Id);
        System.assertEquals(opp.OwnerId , sr.OwnerId);
        System.assertEquals(opp.RecordTypeId , recordTypeId);
    }
}