@isTest
private with sharing class ETH_MinMaxSalaryFindTest {
    /**
     * @testSetup method to create reusable test data
     * Runs once before all test methods to avoid redundant setup
     */
    @testSetup
    static void setupTestData() {
        // ✅ Create Tech Firms
        List<Tech_Firm__c> techFirms = new List<Tech_Firm__c>{
            new Tech_Firm__c(Name = 'Tech Firm A'),
            new Tech_Firm__c(Name = 'Tech Firm B')
        };
        insert techFirms;

        // ✅ Create Employees with different salaries assigned to the Tech Firms
        List<Employee__c> employees = new List<Employee__c>{
            new Employee__c(Name = 'Emp 1', Salary__c = 50000, Tech_Firm__c = techFirms[0].Id),
            new Employee__c(Name = 'Emp 2', Salary__c = 70000, Tech_Firm__c = techFirms[0].Id),
            new Employee__c(Name = 'Emp 3', Salary__c = 60000, Tech_Firm__c = techFirms[1].Id),
            new Employee__c(Name = 'Emp 4', Salary__c = 90000, Tech_Firm__c = techFirms[1].Id)
        };
        insert employees;
    }

    @isTest
    static void testUpdateTechFirmSalaries() {
        // ✅ Fetch test Employees
        List<Employee__c> employees = [SELECT Id, Salary__c, Tech_Firm__c FROM Employee__c];

        // ✅ Call method under test
        Test.startTest();
        ETH_MinMaxSalaryFind.updateTechFirmSalaries(employees, new Map<Id, Employee__c>());
        Test.stopTest();

        // ✅ Verify Tech Firm records are updated
        List<Tech_Firm__c> updatedTechFirms = [SELECT Id, Min_Salary__c, Max_Salary__c FROM Tech_Firm__c];
        
        for (Tech_Firm__c tf : updatedTechFirms) {
            System.assert(tf.Min_Salary__c > 0, 'Min Salary should be set');
            System.assert(tf.Max_Salary__c > 0, 'Max Salary should be set');
        }
    }

    @isTest
    static void testSalaryChange() {
        // ✅ Fetch an employee and increase their salary
        Employee__c updatedEmployee = [SELECT Id, Salary__c, Tech_Firm__c FROM Employee__c WHERE Salary__c = 70000 LIMIT 1];
        Map<Id, Employee__c> oldMap = new Map<Id, Employee__c>();
        oldMap.put(updatedEmployee.Id, updatedEmployee);

        updatedEmployee.Salary__c = 100000; // Increase salary
        update updatedEmployee;

        // ✅ Call method under test
        Test.startTest();
        ETH_MinMaxSalaryFind.updateTechFirmSalaries(new List<Employee__c>{updatedEmployee}, oldMap);
        Test.stopTest();

        // ✅ Verify updated values
        Tech_Firm__c updatedTechFirm = [SELECT Min_Salary__c, Max_Salary__c FROM Tech_Firm__c WHERE Id = :updatedEmployee.Tech_Firm__c];
        System.assertEquals(50000, updatedTechFirm.Min_Salary__c, 'Min Salary should remain unchanged');
        System.assertEquals(100000, updatedTechFirm.Max_Salary__c, 'Max Salary should be updated');
    }

    @isTest
    static void testEmployeeTransfer() {
        // ✅ Fetch an employee and move them to another Tech Firm
        Employee__c movedEmployee = [SELECT Id, Salary__c, Tech_Firm__c FROM Employee__c WHERE Salary__c = 50000 LIMIT 1];
        Map<Id, Employee__c> oldMap = new Map<Id, Employee__c>();
        oldMap.put(movedEmployee.Id, movedEmployee);

        List<Tech_Firm__c> techFirms = [SELECT Id FROM Tech_Firm__c WHERE Id != :movedEmployee.Tech_Firm__c LIMIT 1];
        movedEmployee.Tech_Firm__c = techFirms[0].Id;
        update movedEmployee;

        // ✅ Call method under test
        Test.startTest();
        ETH_MinMaxSalaryFind.updateTechFirmSalaries(new List<Employee__c>{movedEmployee}, oldMap);
        Test.stopTest();

        // ✅ Verify both old and new Tech Firms are updated
        List<Tech_Firm__c> updatedTechFirms = [SELECT Min_Salary__c, Max_Salary__c FROM Tech_Firm__c];
        for (Tech_Firm__c tf : updatedTechFirms) {
            System.assertNotEquals(null, tf.Min_Salary__c, 'Min Salary should be updated');
            System.assertNotEquals(null, tf.Max_Salary__c, 'Max Salary should be updated');
        }
    }
}