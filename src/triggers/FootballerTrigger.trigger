trigger FootballerTrigger on Footballer__c (before insert, before update, before delete, after insert, after update, after delete) {
    new FootballerTriggerHandler().execute();
}