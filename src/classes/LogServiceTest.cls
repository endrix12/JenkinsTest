@isTest
public with sharing class LogServiceTest {

    @IsTest
    private static void shouldSuccessCreateLog(){
        List<FootballerManager.Result> results = new List<FootballerManager.Result>();
                String action ='POST';
        List<FootballerManager.FootballerWrapper> footballerWrappers = new List<FootballerManager.FootballerWrapper>();
        List<Footballer__c> footballers = new List<Footballer__c>();
        for (Integer i = 0; i < 10; i++) {
            Footballer__c footballer = new Footballer__c(Name = 'Test' + i);
            FootballerManager.FootballerWrapper footballerWrapper = new FootballerManager.FootballerWrapper();
            footballerWrapper.lastName='footballerWrapper' + i;
            footballers.add(footballer);
            footballerWrappers.add(footballerWrapper);
            results.add(new FootballerManager.Result(true,  footballerWrapper, 'Successs', Date.today().format(), UserInfo.getName()));
        }

        Test.startTest();
        LogService.createLog(results,action,footballers,footballerWrappers);
        Test.stopTest();

        List<Log__c> logs = [SELECT ID FROM Log__c];
        System.assertEquals(logs.size(),10);
    }

    @IsTest
    private static void shouldWhenFootballersNullCreateLog(){
        List<FootballerManager.Result> results = new List<FootballerManager.Result>();
        String action ='delete';
        List<FootballerManager.FootballerWrapper> footballerWrappers = new List<FootballerManager.FootballerWrapper>();
        List<Footballer__c> footballers = new List<Footballer__c>();
        for (Integer i = 0; i < 10; i++) {
            Footballer__c footballer = new Footballer__c(Name = 'Test' + i);
            FootballerManager.FootballerWrapper footballerWrapper = new FootballerManager.FootballerWrapper();
            footballerWrapper.lastName='footballerWrapper' + i;
            footballers.add(footballer);
            footballerWrappers.add(footballerWrapper);
            results.add(new FootballerManager.Result(null,  footballerWrapper, 'Successs', Date.today().format(), UserInfo.getName()));
        }

        Test.startTest();
        LogService.createLog(results,action,null,footballerWrappers);
        Test.stopTest();

        List<Log__c> logs = [SELECT ID FROM Log__c];
        System.assertEquals(logs.size(),10);
    }



}