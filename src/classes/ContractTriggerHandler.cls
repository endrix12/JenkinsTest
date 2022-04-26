public with sharing class ContractTriggerHandler extends TriggerHandler {

    void bulkBefore() {
    }
    void beforeInsert() {
        ContractOverlapService.checkContract();
    }
    void beforeUpdate() {
        ContractOverlapService.checkContract();
    }
    void beforeDelete() {
    }
    void postProcessingBefore() {
    }
    void bulkAfter() {
    }
    void afterInsert() {
    }
    void afterUpdate() {
    }
    void afterDelete() {
    }
    void postProcessingAfter() {
    }
}