@isTest
private class AccountFieldAccessTriggerTest {

    @isTest
    static void testFieldAccessLoggingForRestrictedUser() {
        // Step 1: Get Aryan Profile Id
        Profile aryanProfile = [SELECT Id FROM Profile WHERE Name = 'Aryan Profile' LIMIT 1];

        // Step 2: Create a user with Aryan Profile
        User restrictedUser = new User(
            Alias = 'aryanusr',
            Email = 'aryanuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = aryanProfile.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            UserName = 'aryanuser' + DateTime.now().getTime() + '@test.com'
        );
        insert restrictedUser;

        // Step 3: Run as restricted user
        System.runAs(restrictedUser) {
            // Create a test Account
            Account acc = new Account(Name = 'Audit Test Account');
            insert acc;

            // Try to update VIP_Status__c (should not be allowed)
            acc.VIP_Status__c = 'Gold';
            update acc;
        }

        // Step 4: Verify that Audit Log was created
        List<Audit_Log__c> logs = [SELECT Id, User__c, Field_Name__c, New_Value__c FROM Audit_Log__c WHERE Field_Name__c = 'VIP_Status__c'];

        System.assert(logs.size() > 0, 'Audit log should have been created for restricted user update');
        System.debug('Audit Log: ' + logs[0]);
    }
}