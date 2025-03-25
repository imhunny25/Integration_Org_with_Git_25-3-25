public with sharing class PS_SalesforceTokenUtils {
    public PageReference getAuthCode(){
        /*
			TODO: Get the Custom Metadata Record 
		*/
        
        sfdc_Config__mdt config = sfdc_Config__mdt.getInstance(System.Label.PS_SalesforceTokenLabel);
        System.debug('config -- >> '+ config);
        if(config != null){
            String orgUrl = config.Enviroment__c == 'Production'? 'https://login.salesforce.com' : 'https://test.salesforce.com';
            System.debug('orgUrl -- >> '+ orgUrl);
            String redirect_uri = System.URL.getOrgDomainURL().toExternalForm()+'/apex/'+config.PageName__c;
            System.debug('redirect_uri -- >> '+ redirect_uri);
            String authorizeUrl = orgUrl+config.authurl__c+'?client_id='+config.clientid__c+'&redirect_uri='+redirect_uri+'&response_type=code';
            System.debug( authorizeUrl );
            return new PageReference(authorizeUrl);

        }else{
            return null;
        }
	}
    
    public void getAccessToken(){
        String code = ApexPages.currentPage().getParameters().get('code');
        System.debug(' code -- >>  ' + code );

        sfdc_Config__mdt config = sfdc_Config__mdt.getInstance(System.Label.PS_SalesforceTokenLabel); 
        if(config != null){
            String orgUrl = config.Enviroment__c == 'Production'? 'https://login.salesforce.com' : 'https://test.salesfrocece.com';
            String tokenUrl = orgUrl+config.tokenUrl__c;

            String redirect_uri = System.URL.getOrgDomainURL().toExternalForm()+'/apex/'+config.PageName__c;
            System.debug('redirect_uri --->>> '+ redirect_uri);

            String requestBody = 'code='+code+'&grant_type=authorization_code&client_id='+config.clientid__c+'&client_secret='+config.clientsecret__c+'&redirect_uri='+redirect_uri;
            System.debug('requestBody --->>> '+ requestBody);
            System.debug('tokenUrl --- >>> '+ tokenUrl);
            HttpRequest httpReq = new HttpRequest();
            httpReq.setEndpoint(tokenUrl);
            httpReq.setMethod('POST');
            httpReq.setBody(requestBody);
            httpReq.setHeader('Content-Type','application/x-www-form-urlencoded');
            httpReq.setHeader('Accept','application/json');
            Http http = new Http();
            try{
                HttpResponse httpRes = http.send(httpReq);
                if(httpRes.getStatusCode() == 200){
                    System.debug('httpRes --->>> '+ httpRes.getBody());
                    PS_SalesforceTokenWrapper wrapper = (PS_SalesforceTokenWrapper) JSON.deserialize(httpRes.getBody(), PS_SalesforceTokenWrapper.class);

                    String fullName = 'sfdc_Config.'+System.Label.PS_SalesforceTokenLabel;
                    String label = System.Label.PS_SalesforceTokenLabel;
                    Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
                    fieldWithValuesMap.put('accesstoken__c',wrapper.access_token);
                    //fieldWithValuesMap.put('expires_in__c',wrapper.);
                    fieldWithValuesMap.put('expire_in_time__c', System.now().addHours(2) );
                    fieldWithValuesMap.put('instanceurl__c',wrapper.instance_url);
                    fieldWithValuesMap.put('refreshtoken__c',wrapper.refresh_token);
                    fieldWithValuesMap.put('scope__c',wrapper.scope);
                    fieldWithValuesMap.put('clientid__c',config.clientid__c);
                    fieldWithValuesMap.put('clientsecret__c',config.clientsecret__c);
                    System.debug('SUCCESS \n '+httpRes.getBody());
                    CreateUpdateMetadataUtils.createUpdateMetadata(fullName, label, fieldWithValuesMap);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Successful!'));
                }else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,httpRes.getBody()));
                }
            }catch(System.CalloutException ex){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            }catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            }
        }
    }

    public static Boolean isValid(sfdc_Config__mdt config){
        Boolean isValid = true;
        if(config.expire_in_time__c < System.now()){
            isValid = false;
        }
        return isValid;
    }

    public static Map<String, Object> refreshToken(sfdc_Config__mdt config){
        String orgUrl = config.Enviroment__c == 'Production' ?'https://login.salesforce.com' : 'https://test.salesforce.com';
        String tokenUrl = orgUrl+config.tokenUrl__c;
        String requestBody ='grant_type=refresh_token&client_id='+config.clientid__c+'&client_secret='+config.clientsecret__c+'&refresh_token='+config.refreshtoken__c;

        HttpRequest httpReq = PS_CalloutUtils.prepareRequest(tokenUrl, 'POST', requestBody, 'application/json', 'application/x-www-form-urlencoded');

        Map<String, Object> fieldWithValuesMap =  new Map<String,Object>();

        try {
            HttpResponse httpRes = new Http().send(httpReq);
            if(httpRes.getStatusCode() == 200 || httpRes.getStatusCode() == 201 ){
                PS_SalesforceTokenWrapper wrapper =(PS_SalesforceTokenWrapper)System.JSON.deserialize(httpRes.getBody(), PS_SalesforceTokenWrapper.class);
                fieldWithValuesMap.put('accesstoken__c',wrapper.access_token);
                fieldWithValuesMap.put('expires_in_time__c', System.now().addHours(2) );
            }
        } catch (Exception ex) {
            
        }

        return fieldWithValuesMap;
    }
}