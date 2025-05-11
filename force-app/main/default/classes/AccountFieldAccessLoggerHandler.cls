public class AccountFieldAccessLoggerHandler {
    public static void checkFieldAccess(List<Account> newList, Map<Id, Account> oldMap){
        List<Audit_Log__c> auditLogs = new List<Audit_Log__c>();
        Set<String> monitoredFields = new Set<String>{'VIP_Status__c', 'AnnualRevenue', 'Industry'};
            
            Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.Account.fields.getMap();
        for (Account acc : newList) {
            Account oldAcc = oldMap != null ? oldMap.get(acc.Id) : null;
            for (String fieldName : monitoredFields) {
                if (fieldsMap.containsKey(fieldName)) {
                    Schema.DescribeFieldResult fieldDesc = fieldsMap.get(fieldName).getDescribe();
                    
                    // Check if current user is allowed to update this field
                    if (!fieldDesc.isUpdateable()) {
                        Object newValue = acc.get(fieldName);
                        Object oldValue = oldAcc != null ? oldAcc.get(fieldName) : null;
                        
                        // Log only if value has changed
                        if (newValue != oldValue && (newValue == null || !newValue.equals(oldValue))) {
                            auditLogs.add(new Audit_Log__c(
                                User__c = UserInfo.getUserId(),
                                Field_Name__c = fieldName,
                                Old_Value__c = String.valueOf(oldValue),
                                New_Value__c = String.valueOf(newValue),
                                Account__c = acc.Id,
                                Bypassed_On__c = System.now()
                            ));
                        }
                    }
                }
                
            }
        }
        if (!auditLogs.isEmpty()) {
            insert auditLogs;
        }
    }
}