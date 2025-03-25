public with sharing class AadhaarResponseWrapper {
    @AuraEnabled
    public data data;
    @AuraEnabled
	public String referenceId;	//e4b55ab1-2bff-4a30-8811-65e3bc5095e0
    @AuraEnabled
	public String responseMessage;	//Successfully Completed.
    @AuraEnabled
	public String responseCode;	//SRC001

	public class data {
        @AuraEnabled
		public String aadhaarNumber;	//582798952091
        @AuraEnabled
		public String gender;	//MALE
        @AuraEnabled
		public String mobileNumber;	//
        @AuraEnabled
		public String maskedMobileNumber;	//*******114
        @AuraEnabled
		public String ageBand;	//20-30
        @AuraEnabled
		public String dateOfBirth;	//
        @AuraEnabled
		public String state;	//Rajasthan
        @AuraEnabled
		public String maskAadhaarNumber;	//XXXXXXXX2091
	}
}