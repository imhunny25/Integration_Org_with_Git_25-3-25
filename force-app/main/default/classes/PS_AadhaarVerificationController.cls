public with sharing class PS_AadhaarVerificationController {
    
    @AuraEnabled
    public static AadhaarDetailsWrapper getAadhaarMobileOtp(String aadhaarNumber){
        if(String.isNotBlank(aadhaarNumber) && aadhaarNumber.length() == 12){
            String endPoint = System.Label.Aadhaar_baseurl+'aadhaarOtp';
            String requestBody = 	'{'+ '"aadhaar_number": "'+ aadhaarNumber +'"'+'}';
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endPoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('clientId', System.Label.Aadhaar_clientId);
            request.setHeader('clientSecret', System.Label.Aadhaar_clientSecret);
            request.setHeader('Cookie', 'cookie');
            request.setBody(requestBody);
            System.debug('requestBody --- >>> '+ requestBody);
            System.debug('request: __ '+ request);
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200){
                System.debug('response---> '+response.getBody());
                AadhaarDetailsWrapper wrapper = (AadhaarDetailsWrapper) JSON.deserialize(response.getBody(), AadhaarDetailsWrapper.class);
                System.debug('Wrapper /n' + wrapper);
                return wrapper;
            }
        }
       return null;
    }

    @AuraEnabled
    public static String getAadhaarDetails(String optNumber, String aadhaarNumber){
        if(String.isNotBlank(optNumber) && optNumber.length() == 6){
            String endPoint = System.Label.Aadhaar_baseurl+'aadhaarDetail';
            String requestBody = 	'{'+'"otp": "'+optNumber+'",'+'"aadhaar_number": "'+aadhaarNumber+'"'+'}';
            System.debug('requestBody ---- >>> '+ requestBody);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endPoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('clientId', System.Label.Aadhaar_clientId);
            request.setHeader('clientSecret', System.Label.Aadhaar_clientSecret);
            request.setHeader('Cookie', 'cookie');
            request.setBody(requestBody);
            try {
                HttpResponse response = http.send(request);
                if(response.getStatusCode() == 200){
                    System.debug('response---> '+response.getBody());
                    AadhaarDetailsWrapper wrapper = (AadhaarDetailsWrapper) JSON.deserialize(response.getBody(), AadhaarDetailsWrapper.class);
                    System.debug('Wrapper /n' + wrapper);
                   return JSON.serialize(response.getBody());
                }
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        // String bodyy = '{ "data": { "documentType": "AADHAAR", "name": "Hemraj Kumawat", "dateOfBirth": "1998-07-25", "gender": "MALE", "careOf": "S/O Chouthmal Kumawat", "house": "ward no 09", "street": "new colony", "district": "Nagaur", "subDistrict": "Nawa", "landmark": "", "locality": "", "postOfficeName": "Kuchamancity-d", "state": "Rajasthan", "pincode": "341508", "country": "India", "vtcName": "Kuchaman City", "mobile": "4b02d40acf7ae956dd3b59e7d915eaaf6766e713a45a020cc8f55cde4c24c2b7", "email": "d719040954b6e65c8ad219e1f740fa0474f39d52060d6d69655b5e0cb00e1f77", "photoBase64": "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", "maskAadhaarNumber": "XXXXXXXX2091", "xmlBase64": "" }, "referenceId": "ffa69848-4ebc-4dcf-89de-fb88975a2152", "responseMessage": "Successfully Completed.", "responseCode": "SRC001" }';
        // return bodyy;
        return null;
    }

    @AuraEnabled
    public static AadhaarResponseWrapper aadharVerifier(String aadhaarNumber){
        if(String.isNotBlank(aadhaarNumber)){
            String endPoint = System.Label.Aadhaar_baseurl+'aadhaarVerifier';
            String requestBody = 	'{'+ '"aadhaarNumber": "'+ aadhaarNumber +'"'+'}';
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endPoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('clientId', System.Label.Aadhaar_clientId);
            request.setHeader('clientSecret', System.Label.Aadhaar_clientSecret);
            request.setHeader('Cookie', 'cookie');
            request.setBody(requestBody);
            try {
                HttpResponse response = http.send(request);
                if(response.getStatusCode() == 200){
                    System.debug('response---> '+response.getBody());
                    AadhaarResponseWrapper wrapper = (AadhaarResponseWrapper) JSON.deserialize(response.getBody(), AadhaarResponseWrapper.class);
                    System.debug('Wrapper /n' + wrapper);
                    return wrapper;
                }
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        return null;
        
    }


    public class AadhaarDetailsWrapper{
        @AuraEnabled
        public String referenceId;	//6c368793-a9d6-4e7b-8e81-4a7c1cb3d4b5
        @AuraEnabled
        public String responseMessage;	//OTP either expired or not generated yet. Kindly regenerate OTP.
        @AuraEnabled
        public String responseCode;	//EOE794
    }
}