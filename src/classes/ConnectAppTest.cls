@IsTest
private with sharing class ConnectAppTest {

    @testSetup
    private static void setup() {
        TriggerSwitcher__c triggerSwitcher = new TriggerSwitcher__c(name = 'FootballersTrigger');
        triggerSwitcher.run__c = true;
        insert triggerSwitcher;

    }

    @IsTest
    private static void shouldMakeConnectCallout() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ConnectCalloutMock());
        ConnectApp.makeConnectCallout();
        Test.stopTest();
        System.assertEquals((String) Cache.Org.get('local.myCache.token'), '00D7Q000000I1H7!AREAQHbn7KmydlCygJt0FwBa8SVfDRGnnrHS_baWIi1BykDgJPc4NhRG_occyiGGY9DmHEGIxXVWlAVu.Ra4ZqJPjaJPhWOO');
    }

    @IsTest
    private static void shouldFailMakeConnectCallout() {
        Test.startTest();
        ConnectApp.makeConnectCallout();
        Test.stopTest();
        System.assertNotEquals((String) Cache.Org.get('local.myCache.token'), '00D7Q000000I1H7!AREAQHbn7KmydlCygJt0FwBa8SVfDRGnnrHS_baWIi1BykDgJPc4NhRG_occyiGGY9DmHEGIxXVWlAVu.Ra4ZqJPjaJPhWOO');
    }

    @IsTest
    private static void shouldSuccessInsertFootballer() {
        Test.startTest();
        Map<String, HttpCalloutMock> multiMockMap =
                new Map<String, HttpCalloutMock>();
        multiMockMap.put('callout:Connect', new ConnectCalloutMock());
        multiMockMap.put('callout:FootballerCallout', new FootballerHttpCalloutMock());
        HttpCalloutMock multiMock =
                new MultiRequestMock(multiMockMap);
        Test.setMock(HttpCalloutMock.class, multiMock);

        insert new Footballer__c(
                Name = 'Boniek',
                FirstName__c = 'Zbigniew',
                Country__c = 'Poland',
                Team__c = 'Motor Lublin'
        );

        Test.stopTest();
        Footballer__c footballer = [SELECT Id FROM Footballer__c WHERE Name = 'Boniek'];
        System.assertNotEquals(footballer.Id, '');
    }

    @IsTest
    private static void shouldSuccessUpdateFootballer() {
        Test.startTest();
        Map<String, HttpCalloutMock> multiMockMap =
                new Map<String, HttpCalloutMock>();
        multiMockMap.put('callout:Connect', new ConnectCalloutMock());
        multiMockMap.put('callout:FootballerCallout', new FootballerHttpCalloutMock());
        HttpCalloutMock multiMock =
                new MultiRequestMock(multiMockMap);
        Test.setMock(HttpCalloutMock.class, multiMock);
        Footballer__c footballer = new Footballer__c(Name = 'Dudek', FirstName__c = 'Jerzy', Team__c = 'Real Madryt');
        insert footballer;
        Footballer__c footballerToUpdate = [
                SELECT Id,Name,Team__c
                FROM Footballer__c
                WHERE Name = 'Dudek'
        ];
        footballerToUpdate.Team__c = 'Korona Kielce';
        update footballerToUpdate;
        Test.stopTest();
        Footballer__c footballerAfterUpdate = [
                SELECT Id,Name,Team__c
                FROM Footballer__c
                WHERE Name = 'Dudek'
        ];
        System.assertEquals(footballerAfterUpdate.Team__c, 'Korona Kielce');
    }

    @IsTest
    private static void shouldSuccessDeleteFootballer() {
        Test.startTest();
        Map<String, HttpCalloutMock> multiMockMap =
                new Map<String, HttpCalloutMock>();
        multiMockMap.put('callout:Connect', new ConnectCalloutMock());
        multiMockMap.put('callout:FootballerCallout', new FootballerHttpCalloutMock());
        HttpCalloutMock multiMock =
                new MultiRequestMock(multiMockMap);
        Test.setMock(HttpCalloutMock.class, multiMock);
        Footballer__c footballer = new Footballer__c(Name = 'Dudek', FirstName__c = 'Jerzy', Team__c = 'Real Madryt');
        insert footballer;
        Footballer__c footballerToDelete = [
                SELECT Id,Name,Team__c
                FROM Footballer__c
                WHERE Name = 'Dudek'
        ];
        delete footballerToDelete;
        Test.stopTest();

        Boolean footballerExist = [
                SELECT COUNT()
                FROM Footballer__c
                WHERE Name = 'Dudek'
        ] > 0;
        System.assertEquals(footballerExist, false);
    }

    @IsTest
    private static void shouldFailInsertFootballer() {
        Test.startTest();
        insert new Footballer__c(
                Name = 'Boniek',
                FirstName__c = 'Zbigniew',
                Country__c = 'Poland',
                Team__c = 'Motor Lublin'
        );
        insert new Footballer__c(
                Name = 'Boniek1',
                FirstName__c = 'Zbigniew',
                Country__c = 'Poland',
                Team__c = 'Motor Lublin'
        );
        Test.stopTest();
    }

    @IsTest
    private static void shouldFailDeleteFootballer() {

        Footballer__c footballer1 = new Footballer__c(
                Name = 'Boniek11',
                FirstName__c = 'Zbigniew',
                Country__c = 'Poland',
                Team__c = 'Motor Lublin'
        );
        insert footballer1;
        Footballer__c footballer2 = new Footballer__c(
                Name = 'Boniek22',
                FirstName__c = 'Zbigniew',
                Country__c = 'Poland',
                Team__c = 'Motor Lublin'
        );
        insert footballer2;
        Test.startTest();
        Footballer__c footballerToDelete1 = [SELECT Id FROM Footballer__c WHERE Name = 'Boniek11'];
        Footballer__c footballerToDelete2 = [SELECT Id FROM Footballer__c WHERE Name = 'Boniek22'];
        delete footballerToDelete1;
        delete footballerToDelete2;
        Test.stopTest();
    }

    @IsTest
    private static void shouldFailUpdateFootballer() {

        Footballer__c footballer1 = new Footballer__c(
                Name = 'Name1',
                FirstName__c = 'Zbigniew',
                Country__c = 'Poland',
                Team__c = 'Motor Lublin'
        );
        insert footballer1;
        Footballer__c footballer2 = new Footballer__c(
                Name = 'Name2',
                FirstName__c = 'Zbigniew',
                Country__c = 'Poland',
                Team__c = 'Motor Lublin'
        );
        insert footballer2;
        Test.startTest();
        Footballer__c footballerToUpdate1 = [SELECT Id FROM Footballer__c WHERE Name = 'Name1'];
        footballerToUpdate1.Name = 'updatedName1';
        Footballer__c footballerToUpdate2 = [SELECT Id FROM Footballer__c WHERE Name = 'Name2'];
        footballerToUpdate2.Name = 'updatedName2';
        update footballerToUpdate1;
        update footballerToUpdate2;
        Test.stopTest();
    }

    @IsTest
    private static void shouldSendMailAfterThirdAttemptCalloutDeleting() {
        insert new Footballer__c(
                Name = 'Name1',
                FirstName__c = 'FirstName',
                Country__c = '',
                Team__c = 'Team',
                SynchroAttempt__c = 3
        );

        List<Footballer__c> footballers = [
                SELECT Id, ExternalId__c, Name, FirstName__c, Birthday__c, Country__c, Team__c, Synchronized__c, SynchroAttempt__c
                FROM Footballer__c
                WHERE Name = 'Name1'
        ];

        Test.startTest();
        delete footballers;
        Test.stopTest();
    }

    @IsTest
    private static void shouldInsertFootballerAndCreateLog() {
        Map<String, HttpCalloutMock> multiMockMap =
                new Map<String, HttpCalloutMock>();
        multiMockMap.put('callout:Connect', new ConnectCalloutMock());
        multiMockMap.put('callout:FootballerCallout', new FootballerHttpCalloutMock());
        HttpCalloutMock multiMock =
                new MultiRequestMock(multiMockMap);
        Test.setMock(HttpCalloutMock.class, multiMock);
        insert new Footballer__c(
                Name = 'Name1',
                FirstName__c = 'FirstName',
                Country__c = '',
                Team__c = 'Team'
        );
        List<Footballer__c> footballers = [SELECT Id FROM Footballer__c];
        Set<Id> ids = new Set<Id>();
        for (Footballer__c footballer : footballers) {
            ids.add(footballer.Id);
        }

        Test.startTest();
        List<Log__c> logs = ConnectApp.makeInsertCallout(ids);
        Test.stopTest();

        for (Log__c log : logs) {
            System.assertEquals(log.Message__c, 'Success');
        }
    }

    @IsTest
    private static void shouldUpdateFootballerAndCreateLog() {
        Map<String, HttpCalloutMock> multiMockMap =
                new Map<String, HttpCalloutMock>();
        multiMockMap.put('callout:Connect', new ConnectCalloutMock());
        multiMockMap.put('callout:FootballerCallout', new FootballerHttpCalloutMock());
        HttpCalloutMock multiMock =
                new MultiRequestMock(multiMockMap);
        Test.setMock(HttpCalloutMock.class, multiMock);
        insert new Footballer__c(
                Name = 'Name1',
                FirstName__c = 'FirstName',
                Country__c = 'Poland',
                Team__c = 'Team'
        );
        List<Footballer__c> footballers = [SELECT Id FROM Footballer__c];
        Set<Id> ids = new Set<Id>();
        for (Footballer__c footballer : footballers) {
            ids.add(footballer.Id);
        }

        Test.startTest();
        List<Log__c> logs = ConnectApp.makeUpdateCallout(ids);
        Test.stopTest();

        for (Log__c log : logs) {
            System.assertEquals(log.Message__c, 'Success');
        }
    }

    @IsTest
    private static void shouldDeleteFootballerAndCreateLog() {
        Map<String, HttpCalloutMock> multiMockMap =
                new Map<String, HttpCalloutMock>();
        multiMockMap.put('callout:Connect', new ConnectCalloutMock());
        multiMockMap.put('callout:FootballerCallout', new FootballerHttpCalloutMock());
        HttpCalloutMock multiMock =
                new MultiRequestMock(multiMockMap);
        Test.setMock(HttpCalloutMock.class, multiMock);
        insert new Footballer__c(
                Name = 'Name1',
                FirstName__c = 'FirstName',
                Country__c = 'Poland',
                Team__c = 'Team'
        );
        List<Footballer__c> footballers = [
                SELECT Id,ExternalId__c,Name,FirstName__c,Birthday__c,Age__c,Country__c,Synchronized__c,Team__c,SynchroAttempt__c
                FROM Footballer__c
        ];
        List<FootballerManager.FootballerWrapper> footballerWrappers = new List<FootballerManager.FootballerWrapper>();
        for (Footballer__c footballer : footballers) {
            footballerWrappers.add(FootballerManager.footballerToWrapper(footballer));
        }
        Test.startTest();
        List<Log__c> logs = ConnectApp.makeDeleteCallout(footballerWrappers);
        Test.stopTest();

        for (Log__c log : logs) {
            System.assertEquals(log.Message__c, 'Success');
        }
    }

    @IsTest
    private static void shouldInsertFootballerAndCreateLogWithError() {
        Map<String, HttpCalloutMock> multiMockMap =
                new Map<String, HttpCalloutMock>();
        multiMockMap.put('callout:Connect', new ConnectCalloutMock());
        multiMockMap.put('callout:FootballerCallout', new BadResponseFootballerCalloutMock());
        HttpCalloutMock multiMock =
                new MultiRequestMock(multiMockMap);
        Test.setMock(HttpCalloutMock.class, multiMock);
        insert new Footballer__c(
                Name = 'Name1',
                FirstName__c = 'FirstName',
                Country__c = '',
                Team__c = 'Team'
        );
        List<Footballer__c> footballers = [SELECT Id FROM Footballer__c];
        Set<Id> ids = new Set<Id>();
        for (Footballer__c footballer : footballers) {
            ids.add(footballer.Id);
        }

        Test.startTest();
        List<Log__c> logs = ConnectApp.makeInsertCallout(ids);
        Test.stopTest();

        for (Log__c log : logs) {
            System.assertNotEquals(log.Message__c, 'Success');
        }
    }
}