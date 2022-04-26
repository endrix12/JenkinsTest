public with sharing class FootballerTriggerHandler extends TriggerHandler {

    void switchExecuting() {
        TriggerSwitcher__c triggerSwitcher = TriggerSwitcher__c.getValues('FootballersTrigger');
        isExecuting = triggerSwitcher.run__c;
    }
    void bulkBefore() {
    }
    void beforeInsert() {
        List<Footballer__c> footballersList = trigger.new;
        for (Footballer__c footballer: footballersList) {
            footballer.Synchronized__c = false;
        }
    }
    void beforeUpdate() {
        List<Footballer__c> footballersList = trigger.new;
        for (Footballer__c footballer: footballersList) {
            footballer.Synchronized__c = false;
        }
    }
    void beforeDelete() {
    }
    void postProcessingBefore() {
    }
    void bulkAfter() {
    }
    void afterInsert() {
        List<Footballer__c> newFootballers = (List<Footballer__c>) trigger.new;
        Set<ID> newFootballersIds = new Set<ID>();
        for (Footballer__c footballer : newFootballers) {
            newFootballersIds.add(footballer.ID);
        }
        System.enqueueJob(new AsyncCallout(newFootballersIds, 'insert',null));
    }
    void afterUpdate() {
        List<Footballer__c> newFootballers = (List<Footballer__c>) trigger.new;
        Set<ID> newFootballersIds = new Set<ID>();
        for (Footballer__c footballer : newFootballers) {
            newFootballersIds.add(footballer.ID);
        }
        System.enqueueJob(new AsyncCallout(newFootballersIds,  'update',null));
    }
    void afterDelete() {
        List<Footballer__c> oldFootballers = (List<Footballer__c>) trigger.old;
        List<FootballerManager.FootballerWrapper> footballerWrappers = new List<FootballerManager.FootballerWrapper>();
        for (Footballer__c footballer : oldFootballers) {
            footballerWrappers.add(FootballerManager.footballerToWrapper(footballer));
        }
        System.enqueueJob(new AsyncCallout(null, 'delete', footballerWrappers));
    }
    void postProcessingAfter() {
    }
}