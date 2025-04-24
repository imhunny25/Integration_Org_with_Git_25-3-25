public class PhonePePayloadBuilder {
    public static String buildQrInitPayload(
        String merchantId,
        String transactionId,
        String merchantOrderId,
        Integer amount,
        String storeId,
        String terminalId,
        Integer expiresIn,
        Integer gst,
        Integer cgst,
        Integer cess,
        Integer sgst,
        Integer igst,
        Integer gstIncentive,
        Integer gstPercentage,
        String invoiceNumber,
        DateTime invoiceDate,
        String invoiceName
    ) {
        String formattedInvoiceDate = invoiceDate.format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        Map<String, Object> gstBreakup = new Map<String, Object>{
            'gst' => gst,
            'cgst' => cgst,
            'cess' => cess,
            'sgst' => sgst,
            'igst' => igst,
            'gstIncentive' => gstIncentive,
            'gstPercentage' => gstPercentage
        };

        Map<String, Object> invoiceDetails = new Map<String, Object>{
            'invoiceNumber' => invoiceNumber,
            'invoiceDate' => formattedInvoiceDate,
            'invoiceName' => invoiceName
        };

        Map<String, Object> payload = new Map<String, Object>{
            'merchantId' => merchantId,
            'transactionId' => transactionId,
            'merchantOrderId' => merchantOrderId,
            'amount' => amount,
            'storeId' => storeId,
            'terminalId' => terminalId,
            'expiresIn' => expiresIn,
            'gstBreakup' => gstBreakup,
            'invoiceDetails' => invoiceDetails
        };

        return JSON.serialize(payload);
    }
}