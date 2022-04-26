global with sharing class ScheduleCalloutService implements Schedulable, Database.AllowsCallouts {

    private String action;
    private static final String jobName = 'Retry Sync Job';
    private List<FootballerManager.FootballerWrapper> footballerWrappers;

    public ScheduleCalloutService(String action, List<FootballerManager.FootballerWrapper> footballerWrappers) {
        this.action = action;
        this.footballerWrappers = footballerWrappers;
    }

    global void execute(SchedulableContext ctx) {
        if (action != 'delete') {
            executeForInsertAndUpdateAction(action);
        } else {
            executeForDeleteAction(action);
        }
        System.abortJob(ctx.getTriggerId());
    }

    public static void schedule(
            Integer attempt,
            String action,
            List<FootballerManager.FootballerWrapper> footballerWrappers) {
        if (!isScheduled(action)) {
            if (attempt == 0) {
                System.schedule(
                        jobName + action,
                        Datetime.now().addMinutes(1).format('s m H d M') + ' ? ',
                        new ScheduleCalloutService(action, footballerWrappers));
            } else if (attempt == 1) {
                System.schedule(jobName + action,
                        Datetime.now().addMinutes(10).format('s m H d M') + ' ? ',
                        new ScheduleCalloutService(action, footballerWrappers));
            } else if (attempt == 2) {
                System.schedule(jobName + action,
                        Datetime.now().addMinutes(30).format('s m H d M') + ' ? ',
                        new ScheduleCalloutService(action, footballerWrappers));
            } else if (attempt == 3) {
                resetSyncAttemptInFootballerToSync(footballerWrappers);
                MailService.sendEmail();
            }
        }
    }

    private static void executeForInsertAndUpdateAction(String action) {
        List<Footballer__c> footballersListNoSync = getFootballersNoSync();
        If (!footballersListNoSync.isEmpty()) {
            Set<ID> footbalersIds = new Map<Id, Footballer__c>(footballersListNoSync).keySet();
            System.enqueueJob(new AsyncCallout(footbalersIds, action, null));
            incrementSyncAttempt(footbalersIds);
        }
    }

    private static void executeForDeleteAction(String action) {
        List<FootballerToSync__c> footballersToSyncList = getFootballersToSync();
        If (!footballersToSyncList.isEmpty()) {
            Set<ID> footbalersIds = new Map<Id, FootballerToSync__c>(footballersToSyncList).keySet();
            System.enqueueJob(new AsyncCallout(footbalersIds, action, new List<FootballerManager.FootballerWrapper>()));
            incrementSyncAttemptInFootballerToSync(footbalersIds);
        }
    }

    private static List<Footballer__c> getFootballersNoSync() {
        return [
                SELECT Id
                FROM Footballer__c
                WHERE Synchronized__c = false
        ];
    }

    private static List<FootballerToSync__c> getFootballersToSync() {
        return [
                SELECT Id,ExternalId__c,IdSyncObject__c
                FROM FootballerToSync__c
        ];
    }

    public static void incrementSyncAttempt(Set<ID> footbalersIds) {
        List<Footballer__c> footballers = [
                SELECT Id, SynchroAttempt__c
                FROM Footballer__c
                WHERE Id IN :footbalersIds
        ];
        for (Footballer__c footballer : footballers) {
            footballer.SynchroAttempt__c += 1;
        }
        TriggerSwitcher__c triggerSwitcher = TriggerSwitcher__c.getValues('FootballersTrigger');
        triggerSwitcher.run__c = false;
        update triggerSwitcher;
        update footballers;
        triggerSwitcher.run__c = true;
        update triggerSwitcher;
    }

    public static void incrementSyncAttemptInFootballerToSync(Set<ID> footballersIds) {
        List<FootballerToSync__c> footballersToSync = [
                SELECT Id, SynchroAttempt__c
                FROM FootballerToSync__c
                WHERE Id IN :footballersIds
        ];
        for (FootballerToSync__c footballer : footballersToSync) {
            footballer.SynchroAttempt__c += 1;
        }
        update footballersToSync;
    }

    public static void resetSyncAttemptInFootballerToSync(List<FootballerManager.FootballerWrapper> footballerWrappers) {
        Set<Id> footbalersIds = new Set<Id>();
        for (FootballerManager.FootballerWrapper footballerWrapper : footballerWrappers) {
            footbalersIds.add(footballerWrapper.externalId);
        }
        List<FootballerToSync__c> footballersToSync = [
                SELECT Id,ExternalId__c, SynchroAttempt__c
                FROM FootballerToSync__c
                WHERE ExternalId__c IN :footbalersIds
        ];
        for (FootballerToSync__c footballer : footballersToSync) {
            footballer.SynchroAttempt__c = 0;
        }
        System.debug(footballersToSync);
        update footballersToSync;
    }

    private static Boolean isScheduled(String action) {
        return [
                SELECT COUNT()
                FROM CronTrigger
                WHERE CronJobDetail.Name = :jobName + action
        ] > 0;
    }
}