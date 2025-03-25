public class PS_eSignAadharController {

    @AuraEnabled
    public static String processESignature(String eSignDataPera) {
        ESignDataWrapper eSignData = (ESignDataWrapper) JSON.deserialize(eSignDataPera, ESignDataWrapper.class);
        System.debug('eSignData---------->> '+eSignDataPera);
       
        try {
            // Validate inputs
            if (String.isBlank(eSignData.documentId)) {
                throw new AuraHandledException('Document ID is required');
            }
            if (String.isBlank(eSignData.aadhaarName)) {
                throw new AuraHandledException('Aadhaar Name is required');
            }
            if (String.isBlank(eSignData.aadhaarNumber)) {
                throw new AuraHandledException('Aadhaar Number is required');
            }
            
            List<ContentVersion> contentVersionList = [SELECT Id, VersionData, FileType, Title,
                                                        ContentDocumentId, FileExtension, PathOnClient, ContentUrl,
                                                        VersionNumber,
                                                        ContentSize, ContentModifiedDate
                                                        FROM ContentVersion
                                                        WHERE ContentDocumentId = :eSignData.documentId
                                                        LIMIT 1
                                                    ];
            
            ContentVersion  con = contentVersionList[0];
            String fileName = contentVersionList[0].Title+'.'+contentVersionList[0].FileExtension;
            String referenceData = FileUploadController.uploadFile(fileName, con.VersionData);
            String directUrl =  getKYCResponse(referenceData);
            String ref = sendAadhaarESignRequest(eSignData.aadhaarNumber, eSignData.aadhaarName, directUrl);
            String urlOfInputFile = getKycRequestResponse(ref);
            return urlOfInputFile;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static String getKYCResponse(String referenceId) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        // Set the endpoint URL
        String endpoint = System.Label.ESign_BaseUrl+'getkycrequestresponse?referenceId=' + referenceId;
        String clientId = System.Label.ESign_clientId;
        String clientSecret = System.Label.ESign_clientSecret;
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        
        // Set headers
        request.setHeader('clientSecret', clientSecret);
        request.setHeader('clientId', clientId);
        request.setHeader('Cookie', 'cookie; content-type');
        
        // Callout execution
        HttpResponse response = http.send(request);
        
        // Check response status
        if (response.getStatusCode() == 200) {
            System.debug('Response: ' + response.getBody());
            KycResponseWrapper wrapper = (KycResponseWrapper) JSON.deserialize(response.getBody(), KycResponseWrapper.class);
            System.debug('wrapper -- >> '+ wrapper);
            String directUrl = wrapper.data.file.directURL;
            System.debug('Direct URL: ' + directUrl);
            return directUrl;
        } else {
            System.debug('Error: ' + response.getStatus());
            return null;
        }
    }

    public static String sendAadhaarESignRequest(String aadharNumber, String aadharName, String directedUrl) {
        try {
            System.debug('directedUrl --- >>> '+ directedUrl);
            String endpoint = System.Label.ESign_BaseUrl+'customersAadhaareSign';
            String clientId = System.Label.ESign_clientId;
            String clientSecret = System.Label.ESign_clientSecret;
            // Create HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            
            // Set headers
            req.setHeader('clientId', clientId);
            req.setHeader('clientSecret', clientSecret);
            req.setHeader('Content-Type', 'application/json');
            
            // JSON body
            String requestBody = '{"task": "url",'
                                + '"callbackUrl": "google.com",'
                                + '"uid": "'+aadharNumber+'",'
                                + '"inputFile": "'+directedUrl+'",'
                                + '"name": "'+aadharName+'",'
                                + '"multiPages": "true",'
                                + '"signaturePosition": "",'
                                + '"pageNo": "1",'
                                + '"signatureType": "aadhaaresign",'
                                + '"xCoordinate": "10",'
                                + '"yCoordinate": "10"}';
            
            req.setBody(requestBody);
            
            // Send request
            Http http = new Http();
            HTTPResponse response = http.send(req);
            
            if (response.getStatusCode() == 200) {
                System.debug('Response: ' + response.getBody());
                KycESignResponseWrapper wrapper = (KycESignResponseWrapper) JSON.deserialize(response.getBody(), KycESignResponseWrapper.class);
                System.debug('wrapper -- >> '+ wrapper);
                String directUrl = wrapper.data.referenceId;
                System.debug('Direct URL:  2222 --- >> ' + directUrl);
                return directUrl;
            } else {
                System.debug('Error: ' + response.getStatus());
                return null;
            }
            
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        return null;
    }

    // Step - 4
    public static String getKycRequestResponse(String referenceId) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        // Set the endpoint URL
        String endpoint = System.Label.ESign_BaseUrl+'getkycrequestresponse?referenceId=' + referenceId;
        String clientId = System.Label.ESign_clientId;
        String clientSecret = System.Label.ESign_clientSecret;
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        
        // Set headers
        request.setHeader('clientSecret', clientSecret);
        request.setHeader('clientId', clientId);
        request.setHeader('Cookie', 'cookie; content-type');
        
        // Callout execution
        HttpResponse response = http.send(request);
        
        // Check response status
        if (response.getStatusCode() == 200) {
            System.debug('Response: getKycRequestResponse __ >> ' + response.getBody());
            getKycRequestResponseWrapper wrapper = (getKycRequestResponseWrapper) JSON.deserialize(response.getBody(), getKycRequestResponseWrapper.class);
            System.debug('wrapper -- >> '+ wrapper);
           
            return wrapper.data.result.url;
        } else {
            System.debug('Error: ' + response.getStatus());
            return null;
        }
    }


    public class ESignDataWrapper {
        @AuraEnabled public String documentId;
        @AuraEnabled public String aadhaarName;
        @AuraEnabled public String aadhaarNumber;
    }

    public class KycResponseWrapper {
        public String referenceId;       // Example: 2bb429fb-d47d-4e13-a0cf-ab5b9e479b42
        public String responseMessage;   // Example: Successfully Completed.
        public String responseCode;      // Example: SRC001
        public KycData data;             // Holds file details
    }
    
    public class KycData {
        public KycFile file;
    }
    
    public class KycFile {
        public Integer id;               // Example: 1138184528
        public String filetype;          // Example: application/pdf
        public String directURL;         // Example: File download URL
    }

    public class KycESignResponseWrapper {
        public ReferenceData data;
        public String responseMessage;  // Example: "Successfully Submitted."
        public String responseCode;     // Example: "SRS016"
    }
    
    public class ReferenceData {
        public String referenceId;  // Example: "88675355-a33d-465d-ae26-5386ff77ff47"
    }
}