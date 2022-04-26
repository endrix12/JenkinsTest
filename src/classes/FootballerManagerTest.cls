@IsTest
public with sharing class FootballerManagerTest {

    @testSetup private static void setup() {
        Test.startTest();
        TriggerSwitcher__c triggerSwitcher = new TriggerSwitcher__c(name = 'FootballersTrigger');
        triggerSwitcher.run__c = false;
        insert triggerSwitcher;
        Footballer__c footballer = new Footballer__c(Name = 'Dudek', FirstName__c = 'Jerzy', Team__c = 'Real Madryt');
        insert footballer;
        Test.stopTest();
    }

    @isTest static void shouldSuccessfulInsertFootballer() {
        List<FootballerManager.FootballerWrapper> footballerWrappers = new List<FootballerManager.FootballerWrapper>();
        Footballer__c footballer = new Footballer__c(Name = 'Citko');
        footballerWrappers.add(FootballerManager.footballerToWrapper(footballer));

        Test.startTest();
        List<FootballerManager.Result> results = FootballerManager.insertFootballer(footballerWrappers);
        Test.stopTest();

        Footballer__c insertedFootballer = [SELECT Id,Name FROM Footballer__c WHERE Name = 'Citko'];
        System.assert(insertedFootballer.Name == 'Citko');
        for (FootballerManager.Result result : results) {
            System.assert(result.success);
            System.assert(result.message == 'Success');
        }
    }

    @isTest static void shouldFailInsertFootballer() {
        List<FootballerManager.FootballerWrapper> footballerWrappers = new List<FootballerManager.FootballerWrapper>();
        Footballer__c footballer = new Footballer__c(FirstName__c = 'blablabla');
        footballerWrappers.add(FootballerManager.footballerToWrapper(footballer));

        Test.startTest();
        List<FootballerManager.Result> results = FootballerManager.insertFootballer(footballerWrappers);
        Test.stopTest();

        List<Footballer__c> insertedFootballers = [SELECT Id,Name FROM Footballer__c WHERE FirstName__c = 'blablabla'];
        System.assert(insertedFootballers.isEmpty());
        for (FootballerManager.Result result : results) {
            System.assert(!result.success);
            System.assert(result.message != 'Success');
            System.assert(result.message == 'Last Name can\'t be empty');
        }
    }

    @isTest static void shouldSuccessfulUpdateFootballer() {
        List<FootballerManager.FootballerWrapper> footballerWrappers = new List<FootballerManager.FootballerWrapper>();
        Footballer__c footballerToUpdate = [SELECT Id,ExternalId__c,FirstName__c,Name,Birthday__c,Team__c,Country__c,Synchronized__c,SynchroAttempt__c FROM Footballer__c WHERE Name = 'Dudek'];
        footballerToUpdate.Team__c = 'Korona Kielce';
        FootballerManager.FootballerWrapper footballerWrappertoUpdate = FootballerManager.footballerToWrapper(footballerToUpdate);
        footballerWrappertoUpdate.externalId = footballerWrappertoUpdate.id;
        footballerWrappers.add(footballerWrappertoUpdate);

        Test.startTest();
        List<FootballerManager.Result> results = FootballerManager.updateFootballer(footballerWrappers);
        Test.stopTest();

        Footballer__c updatedFootballer = [SELECT Id,FirstName__c,Name,Team__c FROM Footballer__c WHERE Name = 'Dudek'];
        System.assert(updatedFootballer.Name == 'Dudek' && updatedFootballer.Team__c == 'Korona Kielce');
        for (FootballerManager.Result result : results) {
            System.assert(result.success);
            System.assert(result.message == 'Success');
        }
    }

    @isTest static void shouldFailUpdateFootballer() {
        List<FootballerManager.FootballerWrapper> footballerWrappers = new List<FootballerManager.FootballerWrapper>();
        Footballer__c footballerToUpdate = [SELECT Id,ExternalId__c,FirstName__c,Name,Birthday__c,Team__c,Country__c,Synchronized__c,SynchroAttempt__c FROM Footballer__c WHERE Name = 'Dudek'];
        footballerToUpdate.Team__c = 'Korona Kielce';
        footballerToUpdate.Name = '';
        FootballerManager.FootballerWrapper footballerWrappertoUpdate = FootballerManager.footballerToWrapper(footballerToUpdate);
        footballerWrappertoUpdate.externalId = footballerWrappertoUpdate.id;
        footballerWrappers.add(footballerWrappertoUpdate);

        Test.startTest();
        List<FootballerManager.Result> results = FootballerManager.updateFootballer(footballerWrappers);
        Test.stopTest();

        Footballer__c updatedFootballer = [SELECT Id,FirstName__c,Name,Team__c FROM Footballer__c WHERE Name = 'Dudek'];
        System.assert(updatedFootballer.Name == 'Dudek' && updatedFootballer.Team__c == 'Real Madryt');
        for (FootballerManager.Result result : results) {
            System.assert(!result.success);
            System.assert(result.message == 'Last Name can\'t be empty');
        }
    }

    @isTest static void shouldSuccessfulDeleteFootballer() {
        List<FootballerManager.FootballerWrapper> footballerWrappers = new List<FootballerManager.FootballerWrapper>();
        Footballer__c footballerToDelete = [
                SELECT Id,ExternalId__c,FirstName__c,Name,Birthday__c,Team__c,Country__c,Synchronized__c,SynchroAttempt__c
                FROM Footballer__c
                WHERE Name = 'Dudek'
        ];
        FootballerManager.FootballerWrapper footballerWrappertoDelete = FootballerManager.footballerToWrapper(footballerToDelete);
        footballerWrappertoDelete.externalId = footballerWrappertoDelete.id;
        footballerWrappers.add(footballerWrappertoDelete);
        RestRequest restRequest = new RestRequest();
        restRequest.httpMethod = 'DELETE';
        restRequest.requestUri = 'https://britenet-ba-dev-ed.my.salesforce.com/services/apexrest/Footballer';
        restRequest.requestBody = Blob.valueOf('{"footballerWrappers":' + JSON.serialize(footballerWrappers) + '}');
        RestContext.request = restRequest;

        Test.startTest();
        List<FootballerManager.Result> results = FootballerManager.deleteFootballer();
        Test.stopTest();

        List<Footballer__c> deletedFootballers = [SELECT Id,FirstName__c,Name,Team__c FROM Footballer__c WHERE Name = 'Dudek'];
        System.assert(deletedFootballers.isEmpty());
        for (FootballerManager.Result result : results) {
            System.assert(result.success);
            System.assert(result.message == 'Success');
        }
    }

    @isTest static void shouldFailDeleteFootballer() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduseruwgeyuifgwearsgsdgsdufiafgui@testorg.com');

        List<FootballerManager.FootballerWrapper> footballerWrappers = new List<FootballerManager.FootballerWrapper>();
        Footballer__c footballerToDelete = [
                SELECT Id,ExternalId__c,FirstName__c,Name,Birthday__c,Team__c,Country__c,Synchronized__c,SynchroAttempt__c
                FROM Footballer__c
                WHERE Name = 'Dudek'
        ];

        FootballerManager.FootballerWrapper footballerWrappertoDelete = FootballerManager.footballerToWrapper(footballerToDelete);
        footballerWrappertoDelete.externalId = footballerWrappertoDelete.id;
        footballerWrappers.add(footballerWrappertoDelete);
        RestRequest restRequest = new RestRequest();
        restRequest.httpMethod = 'DELETE';
        restRequest.requestUri = 'https://britenet-ba-dev-ed.my.salesforce.com/services/apexrest/Footballer';
        restRequest.requestBody = Blob.valueOf('{"footballerWrappers":' + JSON.serialize(footballerWrappers) + '}');
        RestContext.request = restRequest;


        System.runAs(u) {
            Test.startTest();
            List<FootballerManager.Result> results = FootballerManager.deleteFootballer();
            Test.stopTest();

            List<Footballer__c> deletedFootballers = [SELECT Id,FirstName__c,Name,Team__c FROM Footballer__c WHERE Name = 'Dudek'];
            System.assert(!deletedFootballers.isEmpty());
            for (FootballerManager.Result result : results) {
                System.assert(!result.success);
                System.assert(result.message != 'Success');
            }
        }
    }
}