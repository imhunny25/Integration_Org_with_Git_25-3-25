trigger AccountTrigger on Account (before insert, before update, after insert, after update, before delete) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        ATH_TotalBudgetDistribuetHandler.distributeTotalBudget(Trigger.new, Trigger.oldMap);
        AccountFieldAccessLoggerHandler.checkFieldAccess(Trigger.new, Trigger.oldMap);
    }
    
    if(Trigger.isBefore && Trigger.isInsert){
        ATH_RestrictAccountCreation.restrictAccountCreation(Trigger.new);
        AccountFieldAccessLoggerHandler.checkFieldAccess(Trigger.new, Trigger.oldMap);
    }
    
    if(Trigger.isBefore && Trigger.isDelete){
        ATH_PreventDeletionPotentialByuer.preventDeletionPontentialBuyer(Trigger.old);
    }
}