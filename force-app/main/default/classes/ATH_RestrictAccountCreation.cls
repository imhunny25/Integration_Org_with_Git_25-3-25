/** 
 * Question: Create a trigger that restricts the creation of an Account 
 * based on a Custom Setting that defines the allowed Industry Types.
 * 
 * Editor: Hemraj Kumawat
 * Date : 1 Apiral 2025
 */
public with sharing class ATH_RestrictAccountCreation {
    public static void restrictAccountCreation(List<Account> newAccounts){
        // Fetch allowed industry types from Custom Settings
        Map<String, Industry_Settings__c> allowedIndustries = Industry_Settings__c.getAll();
        System.debug('allowedIndustries -- ** '+ allowedIndustries);

        for(Account acc : newAccounts){
            if(acc.Industry != null && !allowedIndustries.containsKey(acc.Industry)){
                acc.addError('You are not allowed to create Account with Industry '+ acc.Industry);
            }
        }

    }
}