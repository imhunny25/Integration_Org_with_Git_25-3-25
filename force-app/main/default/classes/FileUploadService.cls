public class FileUploadService {
    public static void uploadPdfFile() {
        // Get the file data from ContentVersion
        ContentVersion cv = [SELECT Title, VersionData FROM ContentVersion WHERE Id =: '068NS00000KLNNtYAP' LIMIT 1];
		
        String fileName = cv.Title+'.pdf';
        // Define boundary
        String boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW';

        // Prepare HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://sm-kyc-sync-prod.scoreme.in/kyc/external/eSignFileUpload');
        req.setMethod('POST');
        req.setHeader('clientId', 'ca81c08a3d44307421fcaf5ea4ef2d5f'); // Store securely
        req.setHeader('clientSecret', '15eba29203beffa4660741f6d4aed50315486cdbf99fbc5d58c3b2ba323630ef'); // Store securely
        req.setHeader('Cookie', 'cookie; content-type');
        req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
        req.setHeader('Accept', 'application/json');

        // Construct multipart form-data body
        Blob startBlob = Blob.valueOf('--' + boundary + '\r\n' +
            'Content-Disposition: form-data; name="files"; filename="' + fileName + '"\r\n' +
            'Content-Type: application/pdf\r\n\r\n');

        Blob endBlob = Blob.valueOf('\r\n--' + boundary + '--');

        // Combine Blobs using Hex encoding
        String combinedHexData = EncodingUtil.convertToHex(startBlob) + EncodingUtil.convertToHex(cv.VersionData) + EncodingUtil.convertToHex(endBlob);
        Blob finalBlob = EncodingUtil.convertFromHex(combinedHexData);

        // Set the body as Blob
        req.setBodyAsBlob(finalBlob);

        // Set content length
        req.setHeader('Content-Length', String.valueOf(finalBlob.size()));

        // Send HTTP request
        Http http = new Http();
        HTTPResponse res = http.send(req);

        // Debug Response
        System.debug('Response Status: ' + res.getStatus());
        System.debug('Response Status Code: ' + res.getStatusCode());
        System.debug('Response Body: ' + res.getBody());
        System.debug('Response Headers: ' + res.getHeaderKeys());
    }
}