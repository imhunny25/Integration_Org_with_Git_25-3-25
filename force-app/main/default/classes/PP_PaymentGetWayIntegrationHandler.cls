public class PP_PaymentGetWayIntegrationHandler {
    public static String saltKey = '3709d36a-f6ca-4c85-b6c9-cb45db412447';
    public static String saltIndex = '1';
    public static String merchantId = 'PEHNAVARAJSTNUAT';
    public static Integer expiresIn = 1500;
    public static String storeId = 'teststore1';
    
    public static void generateQRCode() {
        String transactionId = generateTransactionId();
        
        DateTime now = DateTime.now();
        String currentTimestamp = now.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        
        String payloadJson = PhonePePayloadBuilder.buildQrInitPayload(
            merchantId,
            transactionId,
            transactionId,
            1000,
            storeId,
            'testterminal1',
            expiresIn,
            100, 25, 25, 25, 25, 25, 25,
            '123987',
            now,
            'Test'
        ); 
        //String payloadJson = '{ "merchantId": "PEHNAVARAJSTNUAT", "transactionId": "TX1743844363127-941890", "merchantOrderId": "TX1743844363127-941890", "amount": 10000, "storeId": "teststore1", "terminalId": "testterminal1", "expiresIn": 1500, "gstBreakup": { "gst": 100, "cgst": 26, "cess": 44, "sgst": 15, "igst": 35, "gstIncentive": 10, "gstPercentage": 11 }, "invoiceDetails": { "invoiceNumber": "123987", "invoiceDate": "2025-04-05T14:42:43.129Z", "invoiceName": "Test" } }';
        System.debug('payloadJson -- >> '+ payloadJson);
        String base64Payload = EncodingUtil.base64Encode(Blob.valueOf(payloadJson));
        System.debug('base64Payload -- >> '+ base64Payload);
        
        // 🔐 Signature as per documentation
        String stringToSign = base64Payload + '/v3/qr/init' + saltKey;
        
        System.debug('stringToSign -- >> '+ stringToSign);
        
        Blob sha256Signature = Crypto.generateDigest('SHA-256', Blob.valueOf(stringToSign));
        String hexSignature = EncodingUtil.convertToHex(sha256Signature);
        String xVerify = hexSignature + '###' + saltIndex;
        System.debug('xVerify -- >> '+ xVerify);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://mercury-uat.phonepe.com/enterprise-sandbox/v3/qr/init'); // ✅ matches /v3/qr/init
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('X-VERIFY', xVerify);
        req.setHeader('X-MERCHANT-ID', merchantId);
        req.setHeader('X-CALLBACK-URL', 'https://webhook.site/131a0abd-c3cb-4255-aae3-22a3504fd3d3'); // Replace with your webhook.site URL if testing
        // req.setHeader('X-PROVIDER-ID', 'your_provider_id'); // Optional
        
        // 🚀 Set body with base64 payload
        Map<String, Object> bodyWrapper = new Map<String, Object>{
            'request' => base64Payload
                };
                    System.debug('bodyWrapper -- >> '+ bodyWrapper);
        //req.setBody(String.valueOf(bodyWrapper));
        System.debug('bodyWrapper -- >> --- <<< '+ JSON.serialize(bodyWrapper));
        req.setBody(JSON.serialize(bodyWrapper));
        
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('PhonePe Response: ' + res.getBody());
    }
    
    public static String generateTransactionId() {
        Long timestamp = DateTime.now().getTime();
        Integer randomPart = Math.mod(Crypto.getRandomInteger(), 1000000);
        return 'TX' + String.valueOf(timestamp) + String.valueOf(randomPart);
    }
}