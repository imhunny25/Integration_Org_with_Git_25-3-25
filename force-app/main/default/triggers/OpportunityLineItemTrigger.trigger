trigger OpportunityLineItemTrigger on OpportunityLineItem (after insert, after delete) {
    if(Trigger.isAfter && Trigger.isInsert){
        OLIH_CalculateTotalProduct.calculateTotalProducts(Trigger.new);
    }else if(Trigger.isAfter && Trigger.isDelete){
        OLIH_CalculateTotalProduct.calculateTotalProducts(Trigger.old);                
    }
}