public with sharing class AsyncCallout implements Queueable, Database.AllowsCallouts {

    private Set<ID> footballersIds;
    private String action;
    private List<FootballerManager.FootballerWrapper> footballerWrappers;

    public AsyncCallout(Set<ID> footballersIds, String action, List<FootballerManager.FootballerWrapper> footballerWrappers) {
        this.footballersIds = footballersIds;
        this.action = action;
        this.footballerWrappers = footballerWrappers;
    }

    public void execute(QueueableContext context) {
        List<Log__c> logs = new List <Log__c>();
        if (action == 'insert') {
            logs = ConnectApp.makeInsertCallout(footballersIds);
        } else if (action == 'update') {
            logs = ConnectApp.makeUpdateCallout(footballersIds);
        } else if (action == 'delete') {
            logs = ConnectApp.makeDeleteCallout(footballerWrappers);
        }

        if (isRetryNeeded(logs) && action != 'delete') {
            ScheduleCalloutService.schedule(getAttempts(footballersIds), action, footballerWrappers);
        } else if (isRetryNeeded(logs) && action == 'delete') {
            createFootballersToSync(footballerWrappers);
            ScheduleCalloutService.schedule(getAttemptsWhenDelete(), action, footballerWrappers);
        }
    }

    private Boolean isRetryNeeded(List<Log__c> logs) {
        Boolean isRetryNeeded = false;
        for (Log__c log : logs) {
            if (log.Success__c == false) {
                isRetryNeeded = true;
                break;
            }
        }
        return isRetryNeeded;
    }

    public Integer getAttemptsWhenDelete() {
        return (Integer) [
                SELECT SynchroAttempt__c
                FROM FootballerToSync__c
                LIMIT 1
        ].SynchroAttempt__c;
    }

    public Integer getAttempts(Set<ID> footballersIds) {
        return (Integer) [
                SELECT SynchroAttempt__c
                FROM Footballer__c
                WHERE Id IN :footballersIds
                LIMIT 1
        ].SynchroAttempt__c;
    }

    public static void createFootballersToSync(List<FootballerManager.FootballerWrapper> footballerWrappers) {
        List<FootballerToSync__c> existFootballersToSync = [SELECT ExternalId__c FROM FootballerToSync__c];
        List<String> existFootballersToSyncExternalId = new List<String>();
        for (FootballerToSync__c footballerToSync : existFootballersToSync) {
            existFootballersToSyncExternalId.add(footballerToSync.ExternalId__c);
        }
        List<FootballerToSync__c> newFootballersToSync = new List<FootballerToSync__c>();
        for (FootballerManager.FootballerWrapper footballerWrapper : footballerWrappers) {
            if (!existFootballersToSyncExternalId.contains(footballerWrapper.externalId)) {
                FootballerToSync__c footballerToSync = new FootballerToSync__c(
                        IdSyncObject__c = footballerWrapper.id,
                        ExternalId__c = footballerWrapper.externalId,
                        IsRemoved__c = true,
                        SynchroAttempt__c = footballerWrapper.synchronizationCounter
                );
                newFootballersToSync.add(footballerToSync);
            }
        }
        insert newFootballersToSync;
    }
}