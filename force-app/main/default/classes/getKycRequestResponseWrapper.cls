public with sharing class getKycRequestResponseWrapper {
    public data data;
	public String referenceId;	//88322001-7abe-461a-a14a-dfd6d7fdf54b
	public String responseMessage;	//Successfully Completed.
	public String responseCode;	//SRC001
    
	public class data {
		public result result;
	}
	public class result {
		public String url;	//https://contracting-v2.signzy.app/92ba149e-70fd-4f82-acfa-64def7fc497e/main
		public String inputFile;	//https://persist.signzy.tech/api/files/1138842537/download/525e9a550840413ca6a776bc00f512e6ddcca133980f4ca3b79262ce7437381f.pdf
		public String name;	//Hemraj Kumawat
		public String provider;	//EMUDHRA
		public Integer expiryTimestamp;	//0
	}
}