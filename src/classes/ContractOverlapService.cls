public with sharing class ContractOverlapService {

    private static Boolean isConflict(Contract__c insertContract, Contract__c oldContract) {
        return (insertContract.End_Date__c >= oldContract.Start_Date__c
                && insertContract.Start_Date__c <= oldContract.End_Date__c);
    }

    public static void checkContract() {
        List<Contract__c> newContracts = (List<Contract__c>) trigger.new;
        Set<Id> mechanicIds = new Set<Id>();
        Set<Id> workshopIds = new Set<Id>();
        for (Contract__c contract : newContracts) {
            mechanicIds.add(contract.Mechanic__c);
            workshopIds.add(contract.Workshop__c);
        }

        List<Contract__c> existingContracts = [
                SELECT Mechanic__c, Workshop__c, Name, Start_Date__c, End_Date__c
                FROM Contract__c
                WHERE Mechanic__c IN :mechanicIds
                AND Workshop__c IN :workshopIds
                ORDER BY Start_Date__c
        ];

        for (Integer i = 0; i < newContracts.size() - 1; i++) {
            for (Integer j = i + 1; j < newContracts.size(); j++) {
                if (newContracts.get(i).Mechanic__c == newContracts.get(j).Mechanic__c
                        && newContracts.get(i).Workshop__c == newContracts.get(j).Workshop__c
                        && isConflict(newContracts.get(i), newContracts.get(j))) {
                    newContracts.get(i).addError(System.Label.ContractConflict);
                }
            }
        }

        for (Contract__c newContract : newContracts) {
            String conflictMessage = '';
            for (Contract__c oldContract : existingContracts) {
                if (newContract.Start_Date__c > newContract.End_Date__c) {
                    newContract.addError(System.Label.StartDateEarlier);
                }
                if (oldContract.Mechanic__c == newContract.Mechanic__c
                        && oldContract.Workshop__c == newContract.Workshop__c
                        && isConflict(newContract, oldContract)
                        && oldContract.Id != newContract.Id) {

                    conflictMessage += String.format('{0} {1} {2} {3} {4} {5}', new List<Object>{
                            oldContract.Name, System.Label.StartDate,
                            oldContract.Start_Date__c.format(), System.Label.EndDate,
                            oldContract.End_Date__c.format(), '</br>'
                    });
                }
            }
            if (!String.isEmpty(conflictMessage)) {
                newContract.addError(System.Label.ContractConflict + '</br>' + conflictMessage, false);
            }
        }
    }
}