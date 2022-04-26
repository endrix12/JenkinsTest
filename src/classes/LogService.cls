public with sharing class LogService {

    public static List<Log__c> createLog(
            List<FootballerManager.Result> results,
            String action,
            List<Footballer__c> newFootballers,
            List<FootballerManager.FootballerWrapper> footballerWrappers) {
        List<Log__c> logs = new List<Log__c>();
        Integer counter = 0;
        for (FootballerManager.Result result : results) {
            Log__c log = new Log__c();
            log.Date__c = Date.today();
            log.Success__c = result.success != null ? result.success : false;
            log.Message__c = result != null ? result.message : 'no result';
            log.Footballer__c = action != 'delete' && result.footballerWrapper != null
                    ? result.footballerWrapper.id
                    : (newFootballers != null) ? newFootballers.get(counter).Id : null;
            log.Action__c = action;
            log.SynchroAttempt__c = newFootballers != null
                    ? newFootballers.get(counter).SynchroAttempt__c
                    : footballerWrappers.get(counter).synchronizationCounter;

            log.ExternalId__c = footballerWrappers.get(counter).externalId;
            logs.add(log);
            counter++;
        }
        insert logs;
        return logs;
    }
}