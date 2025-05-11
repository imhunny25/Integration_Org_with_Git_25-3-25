trigger DealTrigger on Deal__c (before insert, before update) {
    if(trigger.isbefore && trigger.isInsert){
        DTH_ValidateDealAmountWithOpp.validateDealAmountWithOpportunity(trigger.new, null);
    }else if(trigger.isbefore && trigger.isUpdate){
        DTH_ValidateDealAmountWithOpp.validateDealAmountWithOpportunity(trigger.new, trigger.oldMap);
    }
}