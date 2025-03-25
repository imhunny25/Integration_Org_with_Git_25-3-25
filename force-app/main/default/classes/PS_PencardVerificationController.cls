public with sharing class PS_PencardVerificationController {
    
    @AuraEnabled
    public static PencardResponseWrapper getPenCardDetails(String pencardNumber){
        if(String.isNotBlank(pencardNumber) && pencardNumber.length() == 10){
            String endPoint = System.Label.Pencard_baseurl+'panDetailInfo';
            String requestBody = '{'+'"pan": "'+pencardNumber+'"'+'}';
            System.debug('requestBody ---- >>> '+ requestBody);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endPoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('clientId', System.Label.Pencard_ClientId);
            request.setHeader('clientSecret', System.Label.Pencard_Clientsecret);
            request.setHeader('Cookie', 'cookie; cookie');
            request.setBody(requestBody);
            try {
                HttpResponse response = http.send(request);
                if(response.getStatusCode() == 200){
                    PencardResponseWrapper wrapper = (PencardResponseWrapper) JSON.deserialize(response.getBody(), PencardResponseWrapper.class);
                    
                   return wrapper;
                }
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        return null;
        
    }
       
}