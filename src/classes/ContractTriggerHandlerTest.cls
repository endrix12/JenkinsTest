@IsTest
private class ContractTriggerHandlerTest {

    @testSetup private static void setup() {
        Test.startTest();
        List<Contract__c> contracts = new List <Contract__c>();
        Mechanic__c mechanic = new Mechanic__c();
        insert mechanic;
        Workshop__c workshop = new Workshop__c();
        insert workshop;
        Date startDate = Date.newInstance(2020, 1, 1);
        Date endDate = Date.newInstance(2020, 1, 12);

        for (Integer i = 0; i < 3; i++) {
            Contract__c contract = new Contract__c(Mechanic__c = mechanic.Id, Workshop__c = workshop.Id,
                    Start_Date__c = startDate.addYears(i), End_Date__c = endDate.addYears(i));
            contracts.add(contract);
        }

        insert contracts;
        Test.stopTest();
    }

    @isTest
    private static void shouldAddContractsSuccess() {
        List<Contract__c> contracts = new List <Contract__c>();
        Mechanic__c mechanic = [SELECT Id FROM Mechanic__c LIMIT 1];
        Workshop__c workshop = [SELECT Id FROM Workshop__c LIMIT 1];
        Date startDate = Date.newInstance(2024, 1, 1);
        Date endDate = Date.newInstance(2024, 1, 12);

        for (Integer i = 0; i < 200; i++) {
            Contract__c contract = new Contract__c(Mechanic__c = mechanic.Id, Workshop__c = workshop.Id,
                    Start_Date__c = startDate.addYears(i), End_Date__c = endDate.addYears(i));
            contracts.add(contract);
        }

        Test.startTest();
        List<Database.SaveResult> results = Database.insert(contracts, false);
        Test.stopTest();

        for (Database.SaveResult result : results) {
            System.assert(result.success);
            System.assert(result.getErrors().isEmpty());
        }
    }

    @isTest
    private static void shouldAddContractsFail() {
        List<Contract__c> contracts = new List <Contract__c>();
        Mechanic__c mechanic = [SELECT Id FROM Mechanic__c LIMIT 1];
        Workshop__c workshop = [SELECT Id FROM Workshop__c LIMIT 1];
        Contract__c contract1 = new Contract__c(Mechanic__c = mechanic.Id, Workshop__c = workshop.Id,
                Start_Date__c = Date.newInstance(2020, 1, 14), End_Date__c = Date.newInstance(2020, 12, 12));
        Contract__c contract2 = new Contract__c(Mechanic__c = mechanic.Id, Workshop__c = workshop.Id,
                Start_Date__c = Date.newInstance(2011, 6, 14), End_Date__c = Date.newInstance(2021, 5, 12));
        Contract__c contract3 = new Contract__c(Mechanic__c = mechanic.Id, Workshop__c = workshop.Id,
                Start_Date__c = Date.newInstance(2012, 6, 14), End_Date__c = Date.newInstance(2022, 5, 12));
        contracts.add(contract1);
        contracts.add(contract2);
        contracts.add(contract3);

        Test.startTest();
        List<Database.SaveResult> results = Database.insert(contracts, false);
        Test.stopTest();

        for (Database.SaveResult result : results) {
            System.assert(!result.success);
            System.assert(!result.getErrors().isEmpty());
            System.assert(result.getErrors().get(0).message.contains(System.Label.ContractConflict));
        }
    }

    @isTest
    private static void shouldUpdateContractsSuccess() {
        List<Contract__c> contracts = [SELECT Id,Start_Date__c,End_Date__c FROM Contract__c];

        for (Contract__c contract : contracts) {
            contract.Start_Date__c = contract.Start_Date__c.addDays(1);
            contract.End_Date__c = contract.End_Date__c.addDays(-1);
        }

        Test.startTest();
        List<Database.SaveResult> results = Database.update(contracts, false);
        Test.stopTest();

        for (Database.SaveResult result : results) {
            System.assert(result.success);
            System.assert(result.getErrors().isEmpty());
        }
    }

    @isTest
    private static void shouldUpdateContractsFail() {
        List<Contract__c> contracts = [SELECT Id,Start_Date__c,End_Date__c FROM Contract__c];

        for (Contract__c contract : contracts) {
            contract.Start_Date__c = contract.Start_Date__c.addDays(5);
            contract.End_Date__c = contract.End_Date__c.addDays(-5);
        }

        Test.startTest();
        List<Database.SaveResult> results = Database.update(contracts, false);
        Test.stopTest();

        for (Database.SaveResult result : results) {
            System.assert(result.success);
            System.assert(result.getErrors().isEmpty());
        }
    }

    @isTest
    private static void shouldAddContractWithStartDateLaterThanEndFail() {
        Mechanic__c mechanic = [SELECT Id FROM Mechanic__c LIMIT 1];
        Workshop__c workshop = [SELECT Id FROM Workshop__c LIMIT 1];
        Contract__c contract = new Contract__c(Mechanic__c = mechanic.Id, Workshop__c = workshop.Id,
                Start_Date__c = Date.newInstance(2024, 6, 14), End_Date__c = Date.newInstance(2023, 5, 12));

        Test.startTest();
        Database.SaveResult result = Database.insert(contract, false);
        Test.stopTest();

        System.assert(!result.success);
        System.assert(!result.getErrors().isEmpty());
        System.assert(result.getErrors().get(0).message.contains(System.Label.StartDateEarlier));
    }
}