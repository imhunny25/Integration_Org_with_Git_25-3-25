/**
* @class ATH_TotalBudgetDistribuetHandler
* @description This class handles the automatic distribution of the Total Budget 
*              of an Account among its related Opportunities whenever the 
*              Total Budget field is updated.
*
* @purpose This is a helper class for a Salesforce trigger that ensures 
*          the budget of an Account is evenly allocated to all its 
*          related Opportunities when the Total_Budget__c field is modified.
*
* @usage This method should be called from an Account trigger (after update)
*        to update the Amount field on related Opportunities.
*
* @author [Hemraj Kumawat]
* @date [25-3-2025]
* Asked in Ey company
*/

public class ATH_TotalBudgetDistribuetHandler {
    
    public static void distributeTotalBudget(List<Account> updatedAccounts, Map<Id, Account> oldAccountMap) {
        
        // Map to store accounts whose Total Budget has changed
        Map<Id, Decimal> accountBudgetMap = new Map<Id, Decimal>();
        
        // Identify accounts where Total Budget has changed
        for (Account updatedAccount : updatedAccounts) {
            if (oldAccountMap != null) {
                Account oldAccount = oldAccountMap.get(updatedAccount.Id);
                if ((updatedAccount.Total_Budget__c != oldAccount.Total_Budget__c) && updatedAccount.Total_Budget__c != null) {
                    accountBudgetMap.put(updatedAccount.Id, updatedAccount.Total_Budget__c);
                }
            }
        }
        
        // Exit if there are no accounts with updated budgets
        if (accountBudgetMap.isEmpty()) {
            return;
        }
        
        // Retrieve related Opportunities for affected accounts
        List<Opportunity> relatedOpportunities = [
            SELECT Id, Amount, AccountId FROM Opportunity WHERE AccountId IN :accountBudgetMap.keySet()
        ];
        
        // Group Opportunities by Account
        Map<Id, List<Opportunity>> accountOpportunitiesMap = new Map<Id, List<Opportunity>>();
        for (Opportunity opp : relatedOpportunities) {
            if (!accountOpportunitiesMap.containsKey(opp.AccountId)) {
                accountOpportunitiesMap.put(opp.AccountId, new List<Opportunity>());
            }
            accountOpportunitiesMap.get(opp.AccountId).add(opp);
        }
        
        // Calculate the budget per Opportunity for each Account
        Map<Id, Decimal> opportunityBudgetMap = new Map<Id, Decimal>();
        for (Id accountId : accountBudgetMap.keySet()) {
            if (accountOpportunitiesMap.containsKey(accountId)) {
                Integer opportunityCount = accountOpportunitiesMap.get(accountId).size();
                if (opportunityCount > 0) {
                    opportunityBudgetMap.put(accountId, accountBudgetMap.get(accountId) / opportunityCount);
                }
            }
        }
        
        // Update Opportunity Amounts based on calculated budgets
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for (Opportunity opp : relatedOpportunities) {
            if (opportunityBudgetMap.containsKey(opp.AccountId)) {
                opp.Amount = opportunityBudgetMap.get(opp.AccountId);
                opportunitiesToUpdate.add(opp);
            }
        }
        
        // Perform update if there are Opportunities to modify
        if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate;
        }
    }
}