@RestResource(urlMapping='/objectFields/*')
global with sharing class DynamicObjectFieldAPI {
    
    @HttpGet
    global static void getObjectFields() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        // Get object name from query parameter
        String objectName = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        
        if (String.isEmpty(objectName)) {
            res.responseBody = Blob.valueOf('{"error": "Object name is required"}');
            res.statusCode = 400;
            return;
        }

        try {
            res.responseBody = Blob.valueOf(JSON.serializePretty(getFieldList(objectName)));
            res.statusCode = 200;
        } catch (Exception e) {
            res.responseBody = Blob.valueOf('{"error": "Invalid object name or insufficient permissions"}');
            res.statusCode = 400;
        }
    }

    private static List<Map<String, Object>> getFieldList(String objectName) {
        List<Map<String, Object>> fieldList = new List<Map<String, Object>>();
        
        // Check if the object exists
        if (!Schema.getGlobalDescribe().containsKey(objectName)) {
            throw new IllegalArgumentException('Invalid object name');
        }

        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

        for (String fieldName : fieldsMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldsMap.get(fieldName).getDescribe();
            Map<String, Object> fieldDetails = new Map<String, Object>();
            fieldDetails.put('name', fieldName);
            fieldDetails.put('label', fieldDescribe.getLabel());
            fieldDetails.put('type', fieldDescribe.getType().name());
            fieldDetails.put('required', !fieldDescribe.isNillable());
            
             // If the field is a picklist, fetch picklist values
            if (fieldDescribe.getType() == Schema.DisplayType.Picklist) {
                List<String> picklistValues = new List<String>();
                for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                    picklistValues.add(entry.getLabel());
                }
                fieldDetails.put('picklistValues', picklistValues);
            }
            
            fieldList.add(fieldDetails);
        }
        return fieldList;
    }
}