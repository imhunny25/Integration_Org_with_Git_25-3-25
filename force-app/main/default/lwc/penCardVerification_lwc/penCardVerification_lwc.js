import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPenCardDetails from '@salesforce/apex/PS_PencardVerificationController.getPenCardDetails';

export default class PenCardVerification_lwc extends LightningElement {

    @track userData ;
    isPencardDetails = true;
    pencardNumber;

    get disableButton(){
        return this.pencardNumber === undefined || this.pencardNumber === '';
    }
    

    pencardNumberHandler(event){
        this.pencardNumber = event.target.value;
    }

    handleClick(){

        if(this.pencardNumber !== undefined && this.pencardNumber !== ''){
            getPenCardDetails({pencardNumber: this.pencardNumber}).then(result => {
                this.userData = result;
                console.log('result --- >> '+ JSON.stringify(this.userData));
                console.log('this.userData.responseMessage --- >> '+ this.userData.responseMessage);
                
                
                this.showToast('success', 'Fetch Data Successfully ', this.userData.responseMessage);
                this.isPencardDetails = false;
            }).catch(error => {
                this.showToast('error', 'Verification Code Failed', error.body.message);
            });
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