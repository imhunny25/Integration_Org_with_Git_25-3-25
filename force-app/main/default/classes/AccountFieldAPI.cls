@RestResource(urlMapping='/accountFields')
global with sharing class AccountFieldAPI {
    
    @HttpGet
    global static void getAccountFields() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serializePretty(getFieldList()));
        res.statusCode = 200;
    }

    private static List<Map<String, Object>> getFieldList() {
        List<Map<String, Object>> fieldList = new List<Map<String, Object>>();
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();

        for (String fieldName : fieldsMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldsMap.get(fieldName).getDescribe();
            Map<String, Object> fieldDetails = new Map<String, Object>();
            fieldDetails.put('name', fieldName);
            fieldDetails.put('label', fieldDescribe.getLabel());
            fieldDetails.put('type', fieldDescribe.getType().name());
            fieldDetails.put('required', !fieldDescribe.isNillable());
            fieldList.add(fieldDetails);
        }
        return fieldList;
    }
}