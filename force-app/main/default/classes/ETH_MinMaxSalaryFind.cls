/**
 * @author Hemraj Kumawat
 * @date March 27, 2025
 * @description This class updates the highest and lowest salaries of employees 
 *              for each Tech Firm in the system. It ensures that salary insights 
 *              remain accurate when employee records are inserted, delete, undelete or updated.
 */

public class ETH_MinMaxSalaryFind {
    /**
    * Updates the Tech Firms with the highest and lowest salaries of their employees.
    * This ensures that each Tech Firm record maintains up-to-date salary insights.
    *
    * @param employeeList List of Employee__c records being inserted or updated.
    * @param oldEmployeeMap Map of old Employee__c records (before update).
    */
    public static void updateTechFirmSalaries(List<Employee__c> employeeList, Map<Id, Employee__c> oldEmployeeMap) {
        Set<Id> techFirmIds = new Set<Id>();

        // ✅ Collect impacted Tech Firm IDs
        for (Employee__c employee : employeeList) {
            if (oldEmployeeMap != null && oldEmployeeMap.containsKey(employee.Id)) {  // ✅ Null check
                Employee__c oldEmployee = oldEmployeeMap.get(employee.Id);
                if (employee.Tech_Firm__c != oldEmployee.Tech_Firm__c) { // ✅ Corrected comparison
                    techFirmIds.add(employee.Tech_Firm__c);
                    techFirmIds.add(oldEmployee.Tech_Firm__c);
                } else {
                    techFirmIds.add(employee.Tech_Firm__c);
                }
            } else {
                techFirmIds.add(employee.Tech_Firm__c);
            }
        }

        if (!techFirmIds.isEmpty()) {
            // ✅ Fetch min/max salary for each Tech Firm
            List<AggregateResult> salaryData = [
                                                SELECT MIN(Salary__c) minSalary, MAX(Salary__c) maxSalary, Tech_Firm__c techFirmId
                                                FROM Employee__c 
                                                WHERE Tech_Firm__c IN :techFirmIds 
                                                GROUP BY Tech_Firm__c
                                                ];

            // ✅ Map to store updated Tech Firm records
            Map<Id, Tech_Firm__c> techFirmMap = new Map<Id, Tech_Firm__c>();

            // ✅ Initialize Tech Firm records with default 0 values
            for (Id techFirmId : techFirmIds) {
                Tech_Firm__c techFirm = new Tech_Firm__c(
                    Id = techFirmId,
                    Min_Salary__c = 0,
                    Max_Salary__c = 0
                );
                techFirmMap.put(techFirmId, techFirm);
            }

            // ✅ Update actual values from Aggregate Query
            for (AggregateResult result : salaryData) {
                Id techFirmId = (Id) result.get('techFirmId');
                if (techFirmMap.containsKey(techFirmId)) {
                    Tech_Firm__c techFirm = techFirmMap.get(techFirmId);
                    techFirm.Max_Salary__c = (Decimal) result.get('maxSalary');
                    techFirm.Min_Salary__c = (Decimal) result.get('minSalary');
                }
            }

            // ✅ Update Tech Firm records
            if (!techFirmMap.isEmpty()) {
                update techFirmMap.values();
            }
        }
   }
}