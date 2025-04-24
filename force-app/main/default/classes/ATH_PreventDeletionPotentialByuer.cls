public class ATH_PreventDeletionPotentialByuer {
    public static void preventDeletionPontentialBuyer(List<Account> oldRecordList){
        Set<String> accountIdsSet = new Set<String>();
        if(!oldRecordList.isEmpty()){
            for(Account acc : oldRecordList){
                accountIdsSet.add(acc.Id);
            }
        }
        
        Map<Id, List<Contact>> accountWithContactMap = new Map<Id,List<Contact>>();
        for(Contact con : [SELECT Id, Name, AccountId FROM Contact WHERE AccountId IN:accountIdsSet AND Potential_Buyer__c = true]){
            if(!accountWithContactMap.containsKey(con.AccountId)){
                accountWithContactMap.put(con.AccountId, new List<Contact>{});
            }
            accountWithContactMap.get(con.AccountId).add(con);
        }
        
        for(Account act : oldRecordList){
            if(accountWithContactMap.containsKey(act.Id)){
               act.addError('This Account cannot be deleted because it has related Contacts marked as Potential Buyers.');
            }
        }
    }
}