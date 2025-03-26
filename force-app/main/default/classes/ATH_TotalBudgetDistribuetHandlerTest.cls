@isTest
public class ATH_TotalBudgetDistribuetHandlerTest {

    /**
     * @testMethod testDistributeTotalBudget
     * @description This test verifies that the total budget is distributed among related opportunities 
     *              when the Total_Budget__c field of an Account is updated.
     */
    @isTest
    static void testDistributeTotalBudget() {
        Test.startTest();

        // Create test Account
        Account testAccount = new Account(Name = 'Test Account', Total_Budget__c = 10000);
        insert testAccount;

        // Create related Opportunities
        List<Opportunity> testOpportunities = new List<Opportunity>{
            new Opportunity(Name = 'Opportunity 1', AccountId = testAccount.Id, StageName = 'Prospecting', CloseDate = Date.today().addDays(30), Amount = 0),
            new Opportunity(Name = 'Opportunity 2', AccountId = testAccount.Id, StageName = 'Prospecting', CloseDate = Date.today().addDays(30), Amount = 0),
            new Opportunity(Name = 'Opportunity 3', AccountId = testAccount.Id, StageName = 'Prospecting', CloseDate = Date.today().addDays(30), Amount = 0)
        };
        insert testOpportunities;

        // Retrieve inserted Opportunities
        List<Opportunity> insertedOpportunities = [SELECT Id, Amount FROM Opportunity WHERE AccountId = :testAccount.Id];
        System.assertEquals(3, insertedOpportunities.size(), 'There should be 3 opportunities created');

        // Update Account's Total Budget
        testAccount.Total_Budget__c = 12000;
        update testAccount;

        // Retrieve updated Opportunities
        List<Opportunity> updatedOpportunities = [SELECT Id, Amount FROM Opportunity WHERE AccountId = :testAccount.Id];

        // Expected distributed budget per Opportunity
        Decimal expectedBudget = 12000 / 3; // Each Opportunity should get an equal share

        // Verify that the budget was distributed correctly
        for (Opportunity opp : updatedOpportunities) {
            System.assertEquals(expectedBudget, opp.Amount, 'Each opportunity should have the updated distributed budget');
        }

        Test.stopTest();
    }
}