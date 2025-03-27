trigger EmployeeTrigger on Employee__c (after insert, after update, after delete, after undelete) {
	if(trigger.isAfter){
        if(trigger.isInsert){
            ETH_MinMaxSalaryFind.updateTechFirmSalaries(Trigger.new, null);
        }else if(trigger.isUpdate){
            ETH_MinMaxSalaryFind.updateTechFirmSalaries(Trigger.new, Trigger.oldMap);
        }else if(trigger.isUnDelete){
            ETH_MinMaxSalaryFind.updateTechFirmSalaries(Trigger.new, null);
        }else if(trigger.isDelete){
            ETH_MinMaxSalaryFind.updateTechFirmSalaries(Trigger.old, null);
        }
    }
}