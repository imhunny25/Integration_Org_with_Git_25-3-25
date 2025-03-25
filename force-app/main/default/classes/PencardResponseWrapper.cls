public class PencardResponseWrapper {
    public data data;
    @AuraEnabled
	public String referenceId;	//ebf1d758-ab95-47e9-a0f2-f8bd258ae65b
    @AuraEnabled
	public String responseMessage;	//Successfully Completed.
    @AuraEnabled
	public String responseCode;	//SRC001
	class data {
        @AuraEnabled
		public String firstName;	//
        @AuraEnabled
		public String lastName;	//MOOLCHAND
        @AuraEnabled
		public String address;	//
        @AuraEnabled
		public String gender;	//MALE
        @AuraEnabled
		public String aadhaarLinked;	//true
        @AuraEnabled
		public String dob;	//1986-08-15
        @AuraEnabled
		public String fullName;	//MOOLCHAND
        @AuraEnabled
		public String maskedAadhaarNumber;	//XXXXXXXX5129
        @AuraEnabled
		public String category;	//P
        @AuraEnabled
		public String pan;	//AWNPC5452D
	}
}