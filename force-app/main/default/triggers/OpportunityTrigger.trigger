trigger OpportunityTrigger on Opportunity (after insert, after update, after undelete, after delete) {
    if(trigger.isAfter){
        if(trigger.isInsert){
            OTH_FindLargestOpportunity.findLargestOpportunityName(Trigger.new, null);
        }else if(trigger.isUpdate){
            OTH_FindLargestOpportunity.findLargestOpportunityName(Trigger.new, Trigger.oldMap);
        }else if(trigger.isUnDelete){
            OTH_FindLargestOpportunity.findLargestOpportunityName(Trigger.new, null);
        }else if(trigger.isDelete){
            OTH_FindLargestOpportunity.findLargestOpportunityName(Trigger.old, null);
        }
    }
}