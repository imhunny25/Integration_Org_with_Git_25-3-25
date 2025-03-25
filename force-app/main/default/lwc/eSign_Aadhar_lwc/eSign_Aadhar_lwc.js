import { LightningElement, track } from 'lwc';
import processESignature from '@salesforce/apex/PS_eSignAadharController.processESignature';

export default class ESign_Aadhar_lwc extends LightningElement {
    kycUrl='';

    @track eSignData = {
        documentId: '',
        aadhaarName: '',
        aadhaarNumber: ''               
    };

    get acceptedFormats() {
        return ['.pdf'];
    }

    nameHandler(event){
        this.eSignData.aadhaarName = event.target.value;
     }
 
     numberHandler(event){
        this.eSignData.aadhaarNumber = event.target.value;
     }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        alert('No. of files uploaded : ' + uploadedFiles.length);
        this.eSignData.documentId = uploadedFiles[0].documentId;
        console.log('documentId -- >> '+ this.eSignData.documentId);
        
    }

    handleeSign() {
        alert(JSON.stringify(this.eSignData));
        processESignature({eSignDataPera : JSON.stringify(this.eSignData)})
        .then(response => {
            console.log('response -- >> '+ response);
            this.kycUrl = response;
        })
        .catch(error => {
            console.log('error -- >> '+ error);
        });
    }

}