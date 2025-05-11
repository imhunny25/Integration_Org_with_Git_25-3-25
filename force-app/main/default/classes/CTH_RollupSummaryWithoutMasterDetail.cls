public class CTH_RollupSummaryWithoutMasterDetail {

    /**
     * Recalculates the number of male and female Contacts for related Accounts
     * whenever Contacts are inserted, updated, or deleted.
     * 
     * 	Question Context: Roll-Up Summary Without Master-Detail
	 *	This loop identifies all affected AccountIds when a Contact is inserted or updated.
	 *	The goal is to recalculate gender counts (Number_of_Males__c and Number_of_Female__c) on related Account.
     *
     * @param newContactList List of new or updated Contact records
     * @param oldContactMap  Old map of Contact records (used in update/delete)
     */
    public static void calculateTotalMaleAndFemal(List<Contact> newContactList, Map<Id, Contact> oldContactMap) {
        Set<Id> accountIdSet = new Set<Id>();

        // Collect affected AccountIds (for insert/update/delete scenarios)
        for (Contact con : newContactList) {
            if (oldContactMap != null && oldContactMap.containsKey(con.Id)) {
                Contact oldCon = oldContactMap.get(con.Id);
                if (oldCon.AccountId != con.AccountId) {
                    if (con.AccountId != null) accountIdSet.add(con.AccountId);
                    if (oldCon.AccountId != null) accountIdSet.add(oldCon.AccountId);
                } else if (con.AccountId != null) {
                    accountIdSet.add(con.AccountId);
                }
            } else if (oldContactMap == null && con.AccountId != null) {
                accountIdSet.add(con.AccountId); // Insert case
            }
        }

        if (!accountIdSet.isEmpty()) {
            // Maps to hold gender counts per Account
            Map<Id, Decimal> maleCountMap = new Map<Id, Decimal>();
            Map<Id, Decimal> femaleCountMap = new Map<Id, Decimal>();

            // Query all Contacts for affected Accounts
            List<Contact> relatedContacts = [
                SELECT Id, Is_Male__c, AccountId
                FROM Contact
                WHERE AccountId IN :accountIdSet
            ];

            // Count males and females
            for (Contact c : relatedContacts) {
                if (c.Is_Male__c == true) {
                    Decimal count = maleCountMap.containsKey(c.AccountId) ? maleCountMap.get(c.AccountId) : 0;
                    maleCountMap.put(c.AccountId, count + 1);
                } else if (c.Is_Male__c == false) {
                    Decimal count = femaleCountMap.containsKey(c.AccountId) ? femaleCountMap.get(c.AccountId) : 0;
                    femaleCountMap.put(c.AccountId, count + 1);
                }
            }

            // Prepare Account updates
            List<Account> accountsToUpdate = new List<Account>();
            for (Id accId : accountIdSet) {
                Decimal maleCount = maleCountMap.containsKey(accId) ? maleCountMap.get(accId) : 0;
                Decimal femaleCount = femaleCountMap.containsKey(accId) ? femaleCountMap.get(accId) : 0;

                accountsToUpdate.add(new Account(
                    Id = accId,
                    Number_of_Males__c = maleCount,
                    Number_of_Female__c = femaleCount
                ));
            }

            // Perform DML
            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate;
            }
        }
    }
}