@RestResource(urlMapping='/v1/PS_ContactManager_With_Standard_Pram/*')
global class PS_ContactManager_With_Standard_Pram {
    @HttpPost
    global static ResponseWrapper processData(Account accountRecord, Contact contactRecord){
        List<Contact> existingContacts = [SELECT Id, FirstName,
                                          LastName, Account.Name FROM Contact WHERE Email =:contactRecord.Email];
        
        ResponseWrapper wrapper = new ResponseWrapper();
        
        if(existingContacts?.size()>0){
            // do nothing
            wrapper.contactRecord = contactRecord;
            wrapper.accountRecord = accountRecord;
            wrapper.status = 'Existing';
            wrapper.message = 'Contact Already Exists with the Same Email';
        }else{
            // Create Account
            insert accountRecord;
            // Create Contact
            contactRecord.AccountId = accountRecord.Id;
            insert contactRecord;
            wrapper.contactRecord = contactRecord;
            wrapper.accountRecord = accountRecord;
            wrapper.status = 'New';
            wrapper.message = 'Data Inserted';
        }
        return wrapper;
    }
    
    global class ResponseWrapper{
        global Account accountRecord;
        global Contact contactRecord;
        global String status; // New, Existing
        global String message; // success,error
    }
}