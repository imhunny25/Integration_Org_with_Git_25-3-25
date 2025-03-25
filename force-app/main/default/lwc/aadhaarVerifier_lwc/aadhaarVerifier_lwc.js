import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAadhaarMobileOtp from '@salesforce/apex/PS_AadhaarVerificationController.getAadhaarMobileOtp';
import getAadhaarDetails from '@salesforce/apex/PS_AadhaarVerificationController.getAadhaarDetails';
import aadharVerifier from '@salesforce/apex/PS_AadhaarVerificationController.aadharVerifier';

export default class AadhaarVerifier_lwc extends LightningElement {
    aadhaarName='';
    aadhaarNumber='';
    otpNumber='';
    isDisabled=true;
    isDisabledNumner = true;
    isDisabledOtp = true;
    isAadhaarVerifiy = true;
    imageSrc;
    @track aadhaarData;

    nameHandler(event){
       this.aadhaarName = event.target.value;
       
       if (this.aadhaarName === null || this.aadhaarName === undefined || this.aadhaarName === ''){
           this.isDisabled = true;
       }else{
           this.isDisabled = false;
        }
    }

    numberHandler(event){
        this.aadhaarNumber = event.target.value;
        if (this.aadhaarNumber === null || this.aadhaarNumber === undefined || this.aadhaarNumber === '') 
            {
            this.isDisabledNumner = true;
        }else{
            this.isDisabledNumner = false;
        }
    }

    otpHandler(event){
        this.otpNumber = event.target.value;
        if (this.otpNumber === null || this.otpNumber === undefined || this.otpNumber === '') 
            {
            this.isDisabledOtp = true;
        }else{
            this.isDisabledOtp = false;
        }
    }

    get disableButton()
    {
       if(this.isDisabled == false && this.isDisabledNumner == false)
            {
            return false;
        }else{
            return true;
        }
       
       
    }

    get disableButtonOtp()
    {
      return this.isDisabledOtp;  
    }

    handleClick(){
        this.isAadhaarVerifiy = false;

        getAadhaarMobileOtp({ aadhaarNumber: this.aadhaarNumber})
        .then(result => {
            console.log('result' + JSON.stringify(result));
            if(result.responseMessage != null){
                this.showToast('success', 'Verification Code', result.responseMessage);
                this.isAadhaarVerifiy = false;
            }else{
                this.isAadhaarVerifiy = true;
            }
           
        })
        .catch(error => {
            this.showToast('error', 'Verification Code Failed', error.body.message);
            console.log(error.body.message);
        })
    }

    handleClickOtp(){

        if(this.otpNumber != null && this.otpNumber != undefined && this.otpNumber != '')
            {
                getAadhaarDetails({optNumber: this.otpNumber, aadhaarNumber:this.aadhaarNumber})
                .then(result =>{
                    //console.log('result' + JSON.stringify(result));
                    this.aadhaarData = JSON.parse(result); 
                    this.isDisabledOtp = true;
                    this.imageSrc = 'data:image/png;base64,' + this.aadhaarData.data.photoBase64;
                    this.showToast('success', 'Fetch Data Successfully ', this.aadhaarData.responseMessage);
                    
                }).catch(error =>{
                    this.showToast('error', 'Verification Code Failed', error.body.message);
                })
            }

    }

    showToast(variant, title, message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}