@RestResource(urlMapping='/v1/PS_ContactManager/*')
global class PS_ContactManager {
    
    @HttpGet
    global Static List<Contact> getContactRecords(){
        String contactId = RestContext.request.requestURI.substringAfterLast('/');
        return[SELECT Id, Name, Phone, Email FROM Contact WHERE Id =: contactId ORDER BY Name desc LIMIT 10];
    }
    
    @HttpPost
    global Static ResponseWrapper processData(InputWrapper input){
        System.debug('input -- >> '+ input);
        List<Contact> existingContactList = [SELECT Id, FirstName, LastName, Email, Account.Name
                                             FROM Contact 
                                             WHERE Email =:input.email AND Email != null];
        ResponseWrapper rWrapper = new ResponseWrapper();
        if(existingContactList?.size()> 0){
            rWrapper.contactRecored = existingContactList.get(0);
            rWrapper.status = 'Existing';
            rWrapper.message = 'Contact Already Exists with the Same Email';
        }else{
            Account acc = new Account();
            acc.Name = input.accountName;
            insert acc;
            
            Contact con = new Contact();
            con.FirstName = input.firstName;
            con.LastName = input.lastName;
            con.Email = input.email;
            con.AccountId = acc.Id;
            insert con;
            
            rWrapper.accountRecord = acc;
            rWrapper.contactRecored = con;
            rWrapper.status = 'New';
            rWrapper.message = 'Sussessfully create Record';  
        }
        return rWrapper;
        
    }
    
    global class InputWrapper {
        global String accountName;
        global String firstName;
        global String lastName;
        global String email;
    }
    
    global class ResponseWrapper{
        global Account accountRecord;
        global Contact contactRecored;
        global String status; // New, Existing
        global String message; // success,error
    }
}