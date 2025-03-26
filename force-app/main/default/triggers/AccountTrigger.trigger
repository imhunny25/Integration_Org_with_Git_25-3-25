trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        ATH_TotalBudgetDistribuetHandler.distributeTotalBudget(Trigger.new, Trigger.oldMap);
    }
}