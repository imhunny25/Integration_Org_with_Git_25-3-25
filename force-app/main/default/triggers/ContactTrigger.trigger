trigger ContactTrigger on Contact (after insert, after update, after delete) {
    
    if(Trigger.isInsert && Trigger.isAfter){
        CTH_RollupSummaryWithoutMasterDetail.calculateTotalMaleAndFemal(trigger.new, null);
    }else if(Trigger.isDelete && Trigger.isAfter){
        CTH_RollupSummaryWithoutMasterDetail.calculateTotalMaleAndFemal(trigger.old, null);
    }else if(Trigger.isUpdate && Trigger.isAfter){
        CTH_RollupSummaryWithoutMasterDetail.calculateTotalMaleAndFemal(trigger.new, trigger.oldMap);
    } 

}