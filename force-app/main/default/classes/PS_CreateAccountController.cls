@RestResource(urlMapping='/v1/PS_CreateAccountController/*')
global class PS_CreateAccountController {
    /** Create an Account - POST */
    @httpPost
    global static Account createAccount(){ // method arguments
        /** Get the information about Request */
        RestRequest req = RestContext.request;
        System.debug(System.JSON.serializePretty(req));
        /** get the request body */
        String requeBody = req.requestBody?.toString(); // Convert Blob into String format
        System.debug('requeBody -- '+requeBody);
        RestResponse res = RestContext.response;
        System.debug(System.JSON.serializePretty(res));
        if(String.isBlank(requeBody)){
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"message": "Request Body can not be blank!"}');
        }
        
        Account acc = new Account();
        acc.Name = UUID.randomUUID().toString();
        acc.Phone = '98876655623';
        return acc;
    }
}