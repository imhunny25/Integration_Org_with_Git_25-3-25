public class OTH_FindLargestOpportunity {
    /**
* This method updates the Max_Opportunity__c field on Account 
* with the name of the Opportunity that has the highest Amount.
*
* @param opportunityList List of Opportunity records being processed.
* @param oldOpportunityMap Map of old Opportunity records (before update) for reference.

@author [Hemraj Kumawat]
* @date [26-3-2025]
* Asked in TCS company
*/
    public static void findLargestOpportunityName(List<Opportunity> opportunityList, Map<Id, Opportunity> oldOpportunityMap) {
        // Set to store Account IDs that need updating
        Set<Id> accountIds = new Set<Id>();
        
        // Identify impacted Account IDs
        for (Opportunity opportunity : opportunityList) {
            if (opportunity.AccountId != null) {  // Ensure AccountId is not null
                if (oldOpportunityMap != null && oldOpportunityMap.containsKey(opportunity.Id)) {
                    Opportunity oldOpportunity = oldOpportunityMap.get(opportunity.Id);
                    
                    // If AccountId has changed, add both old and new Account IDs
                    if (oldOpportunity.AccountId != opportunity.AccountId) {
                        if (oldOpportunity.AccountId != null) accountIds.add(oldOpportunity.AccountId);
                        accountIds.add(opportunity.AccountId);
                    } else {
                        accountIds.add(opportunity.AccountId);
                    }
                } else {
                    accountIds.add(opportunity.AccountId);
                }
            }
        }
        
        // If there are no Accounts to update, exit early
        if (accountIds.isEmpty()) {
            return;
        }
        
        // List to store Accounts that need updates
        List<Account> accountsToUpdate = new List<Account>();
        
        // Query Accounts with their highest-valued Opportunity
        List<Account> accountList = [
            SELECT Id, Max_Opportunity__c, 
            (SELECT Name FROM Opportunities WHERE Amount != NULL ORDER BY Amount DESC LIMIT 1) 
            FROM Account 
            WHERE Id IN :accountIds
        ];
        
        // Update Max_Opportunity__c field with the highest Opportunity Name
        for (Account account : accountList) {
            if (!account.Opportunities.isEmpty()) {
                account.Max_Opportunity__c = account.Opportunities[0].Name;
            } else {
                account.Max_Opportunity__c = '';  // No Opportunities, clear the field
            }
            accountsToUpdate.add(account);
        }
        
        // Perform DML update if there are changes
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}