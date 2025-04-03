/*
    Author: Hemraj Kumawat
    Date: 3-4-25
    Purpose: 
        This method calculates the total number of products (OpportunityLineItems) 
        associated with all Opportunities linked to an Account. The total count is then 
        updated in the custom field 'Number_of_Products__c' on the Account record.

    Business Use Case: 
        Your organization sells products to its customers through opportunities. 
        Each opportunity can have multiple products (Opportunity Line Items) associated with it. 
        The organization wants to keep track of the total number of products sold to each account 
        and display it on the Account record for reporting purposes.

    Pre Work: 
        - Create a custom field on the Account object named 'Number_of_Products__c' (Number) 
          to count the total number of products related to all Opportunities associated with the Account.

    Parameters:
        @param newOpportunityLineItems (List<OpportunityLineItem>): 
            - A list of newly inserted or updated OpportunityLineItem records.
            - This list is used to identify the related Opportunities and update their associated Accounts.

    Returns:
        - No return value. The method updates the 'Number_of_Products__c' field on the Account records.
*/
public class OLIH_CalculateTotalProduct {
   public static void calculateTotalProducts(List<OpportunityLineItem> newOpportunityLineItems) {
    // Set to store unique Opportunity Ids from the incoming OpportunityLineItems
    Set<String> opportunityIds = new Set<String>();
    
    // Map to store AccountId and its corresponding total product count
    Map<Id, Decimal> accountProductCountMap = new Map<Id, Decimal>();
    
    // Extract Opportunity Ids from the incoming OpportunityLineItems
    for (OpportunityLineItem opportunityLineItem : newOpportunityLineItems) {
        if (opportunityLineItem.OpportunityId != null) {
            opportunityIds.add(opportunityLineItem.OpportunityId);
        }
    }
    
    // If there are valid Opportunity Ids, proceed with calculations
    if (!opportunityIds.isEmpty()) {
        List<Account> accountsToUpdate = new List<Account>();
        
        // Query to fetch Opportunity records with associated Account Ids
        List<Opportunity> opportunities = [SELECT Id, AccountId FROM Opportunity WHERE Id IN :opportunityIds];
        
        // Initialize the accountProductCountMap with Account Ids and set initial count to 0
        for (Opportunity opportunity : opportunities) {
            accountProductCountMap.put(opportunity.AccountId, 0);
        }
        
        // Query to count the number of OpportunityLineItems grouped by AccountId
        for (AggregateResult aggregateResult : [SELECT COUNT(Id) totalProducts, Opportunity.AccountId accountId 
                                                FROM OpportunityLineItem 
                                                WHERE Opportunity.AccountId IN :accountProductCountMap.keySet() 
                                                GROUP BY Opportunity.AccountId]) {
            if (accountProductCountMap.containsKey((Id) aggregateResult.get('accountId'))) {
                accountProductCountMap.put((Id) aggregateResult.get('accountId'), (Decimal) aggregateResult.get('totalProducts'));
            }
        }
        
        // Prepare Account records with updated product count
        for (Id accountId : accountProductCountMap.keySet()) {
            Account accountToUpdate = new Account();
            accountToUpdate.Id = accountId;
            accountToUpdate.Number_of_Products__c = accountProductCountMap.get(accountId);
            accountsToUpdate.add(accountToUpdate);
        }
        
        // Perform bulk update if there are records to update
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}
}