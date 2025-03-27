@isTest
public class OTH_FindLargestOpportunityTest {
    /**
     * Test method to verify that findLargestOpportunityName correctly updates Account records.
     */
    @isTest
    static void testFindLargestOpportunityName() {
        // Create Test Account
        Account acc1 = new Account(Name = 'Test Account 1');
        Account acc2 = new Account(Name = 'Test Account 2');
        insert new List<Account>{ acc1, acc2 };

        // Create Opportunities for Account 1
        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity A', 
            Amount = 5000, 
            StageName = 'Prospecting', 
            CloseDate = Date.today().addDays(30), 
            AccountId = acc1.Id
        );

        Opportunity opp2 = new Opportunity(
            Name = 'Opportunity B', 
            Amount = 10000, 
            StageName = 'Negotiation', 
            CloseDate = Date.today().addDays(40), 
            AccountId = acc1.Id
        );

        // Create an Opportunity for Account 2
        Opportunity opp3 = new Opportunity(
            Name = 'Opportunity C', 
            Amount = 15000, 
            StageName = 'Closed Won', 
            CloseDate = Date.today().addDays(50), 
            AccountId = acc2.Id
        );

        insert new List<Opportunity>{ opp1, opp2, opp3 };

        // Create oldMap to simulate record updates
        Map<Id, Opportunity> oldOpportunityMap = new Map<Id, Opportunity>{
            opp1.Id => opp1
        };

        // Call the method
        Test.startTest();
        OTH_FindLargestOpportunity.findLargestOpportunityName(new List<Opportunity>{ opp1, opp2, opp3 }, oldOpportunityMap);
        Test.stopTest();

        // Verify the updated Account values
        Account updatedAcc1 = [SELECT Id, Max_Opportunity__c FROM Account WHERE Id = :acc1.Id];
        Account updatedAcc2 = [SELECT Id, Max_Opportunity__c FROM Account WHERE Id = :acc2.Id];

        // Assertions
        System.assertEquals('Opportunity B', updatedAcc1.Max_Opportunity__c, 'Account 1 should have the highest Opportunity Name.');
        System.assertEquals('Opportunity C', updatedAcc2.Max_Opportunity__c, 'Account 2 should have the highest Opportunity Name.');
    }

    /**
     * Test method to handle scenario where no Opportunities exist.
     */
    @isTest
    static void testFindLargestOpportunityName_NoOpportunities() {
        // Create Test Account without Opportunities
        Account acc = new Account(Name = 'Test Account No Opp');
        insert acc;

        // Call the method with an empty Opportunity list
        Test.startTest();
        OTH_FindLargestOpportunity.findLargestOpportunityName(new List<Opportunity>(), null);
        Test.stopTest();

        // Verify the Account remains unchanged
        Account updatedAcc = [SELECT Id, Max_Opportunity__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(null, updatedAcc.Max_Opportunity__c, 'Account should not have an Opportunity Name.');
    }
}