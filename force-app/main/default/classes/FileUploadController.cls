public class FileUploadController {
    public static String uploadFile(String fileName, Blob fileData) {
        if (String.isBlank(fileName) || fileData == null) {
            throw new FileUploadException('Invalid input: fileName and fileData must not be empty.');
        }

        try {
            // Define boundary
            String endpoint = System.Label.ESign_BaseUrl+'eSignFileUpload';
            String clientId = System.Label.ESign_clientId;
            String clientSecret = System.Label.ESign_clientSecret;
            String boundary = '----WebKitFormBoundary' + EncodingUtil.base64Encode(Crypto.generateAesKey(128)).substring(0, 16);

            // Prepare HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setTimeout(60000); // Set timeout for long-running requests

            // Securely store sensitive headers (Ideally should be in Named Credentials or Custom Metadata)
            req.setHeader('clientId', clientId); 
            req.setHeader('clientSecret', clientSecret); 

            req.setHeader('Cookie', 'cookie; content-type');
            req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
            req.setHeader('Accept', 'application/json');

            // Construct multipart form-data body
            Blob startBlob = Blob.valueOf(
                '--' + boundary + '\r\n' +
                'Content-Disposition: form-data; name="files"; filename="' + fileName + '"\r\n' +
                'Content-Type: application/pdf\r\n\r\n'
            );

            Blob endBlob = Blob.valueOf('\r\n--' + boundary + '--');

            // Combine Blobs using Hex encoding
            String combinedHexData = EncodingUtil.convertToHex(startBlob) + 
                                     EncodingUtil.convertToHex(fileData) + 
                                     EncodingUtil.convertToHex(endBlob);
                                     
            Blob finalBlob = EncodingUtil.convertFromHex(combinedHexData);

            // Set request body
            req.setBodyAsBlob(finalBlob);
            req.setHeader('Content-Length', String.valueOf(finalBlob.size()));

            // Send HTTP request
            Http http = new Http();
            HTTPResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                Map<String, Object> dataMap = (Map<String, Object>) responseMap.get('data');
                System.debug('dataMap -- >> '+ dataMap.get('referenceId'));
                System.debug('File uploaded successfully. Reference ID: ' + responseMap.get('referenceId'));
                return (String) dataMap.get('referenceId');
           
            }else{
                // Handle API Errors
               return handleErrorResponse(res.getBody());
            }

         
        } catch (FileUploadException e) {
            System.debug('File Upload Error: ' + e.getMessage());
            throw e; // Rethrow custom exception
        } catch (CalloutException e) {
            System.debug('Callout Error: ' + e.getMessage());
            throw new FileUploadException('Callout failed: ' + e.getMessage());
        } catch (Exception e) {
            System.debug('Unexpected Error: ' + e.getMessage());
            throw new FileUploadException('Unexpected error occurred: ' + e.getMessage());
        }
    }

    private static String handleErrorResponse(String responseBody) {
        try {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            String responseCode = (String) responseMap.get('responseCode');
            String responseMessage = (String) responseMap.get('responseMessage');
    
            switch on responseCode {
                when 'EPP006' {
                    return 'Error: Password Protected File. ' + responseMessage;
                }
                when 'EUP007' {
                    return 'Error: Technical Issue. ' + responseMessage;
                }
                when 'EIS042' {
                    return 'Error: Information Source Not Working. ' + responseMessage;
                }
                when 'EFT032' {
                    return 'Error: Incorrect File Type. Accepted type: PDF. ' + responseMessage;
                }
                when else {
                    return 'Unknown error occurred. Code: ' + responseCode + ', Message: ' + responseMessage;
                }
            }
        } catch (Exception e) {
            return 'Failed to parse API error response: ' + e.getMessage();
        }
    }
    
    
    public class FileUploadException extends Exception {}
}