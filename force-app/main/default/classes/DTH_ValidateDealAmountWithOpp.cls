/**
 * @description      Trigger to validate that the Deal Amount matches the associated Opportunity Amount.
 * @author           Hemraj Kumawat
 * @triggerPurpose   Write a trigger on the Deal object to validate that the Deal Amount matches 
 *                   the Amount field of the associated Opportunity during record insert or update.
 */
public class DTH_ValidateDealAmountWithOpp {
    public static void validateDealAmountWithOpportunity(List<Deal__c> newDealList, Map<Id, Deal__c> oldDealMap) {
        Set<Id> opportunityIds = new Set<Id>();

        // Collect Opportunity IDs from valid Deal records
        for (Deal__c deal : newDealList) {
            if (deal.Opportunity__c != null && deal.Amount__c != null) {
                opportunityIds.add(deal.Opportunity__c);
            }
        }

        // Query Opportunity amounts
        Map<Id, Decimal> opportunityAmountMap = new Map<Id, Decimal>();
        for (Opportunity opp : [SELECT Id, Amount FROM Opportunity WHERE Id IN :opportunityIds]) {
            opportunityAmountMap.put(opp.Id, opp.Amount);
        }

        // Validate Deal Amounts with Opportunity Amounts
        for (Deal__c deal : newDealList) {
            Decimal oppAmount = opportunityAmountMap.get(deal.Opportunity__c);
            if (deal.Opportunity__c != null && deal.Amount__c != oppAmount) {
                deal.addError('Deal Amount and related Opportunity Amount do not match.');
            }
        }
    }
}