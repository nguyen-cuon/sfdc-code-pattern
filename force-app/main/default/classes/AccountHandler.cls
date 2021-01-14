/*
 * 株式会社CUON（クオン）
 * 作成日：2021/1/13
 * 作成者：Nguyen Minh Phuong
 * 所属　：ビジネスコンサルティング事業部兼プロジェクト開発部
 * 役職　：アカウントエンジニア
 */
public with sharing class AccountHandler {
    //To avoice recursive in apex trigger
    public static Boolean isStarted = false;
    
    @future(callout=true)
    public static void insertAccount(Set<Id> ids) {
        doCalloutToInsertAccount(ids);
    }

    @future(callout=true)
    public static void updateAccount(Set<Id> ids) {
        doCalloutToUpdateAccount(ids);
    }

    @future(callout=true)
    public static void deleteAccount(Set<Id> ids) {
        doCalloutToDeleteAccount(ids);
    }

    public static void doCalloutToInsertAccount(Set<Id> ids) {

    }

    public static void doCalloutToUpdateAccount(Set<Id> ids) {

    }

    public static void doCalloutToDeleteAccount(Set<Id> ids) {

    }
}