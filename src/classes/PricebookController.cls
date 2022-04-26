public with sharing class PricebookController {
    public PricebookController() {

    }

    @AuraEnabled
    public static List<Pricebook2> getPricebooks(){     
         return [SELECT ID ,Name,IsActive,IsStandard
                FROM Pricebook2];
    }

    @AuraEnabled
    public static Pricebook2 getPricebookById(String pricebookId){     
         return  [SELECT Id, Name, ValidFrom, ValidTo, IsStandard, IsActive, Discount__c
         FROM Pricebook2
         WHERE Pricebook2.Id=:pricebookId];
    }

    @AuraEnabled
    public static List<PricebookEntry> getProductsByPricebookId(String pricebookId){
         return [SELECT ID,Product2.ID,Product2.Name,Product2.Producer__c,Product2.Main_Image__c, Product2.Category__c, PricebookEntry.UnitPrice, IsDiscounted__c,PriceBeforeDiscount__c
                FROM PricebookEntry 
                WHERE Pricebook2.ID =:pricebookId];
    }
    
    @AuraEnabled
    public static void addPricebook(String pricebookName){  
     Pricebook2 pricebook = new Pricebook2(Name = pricebookName);
     Database.SaveResult result = Database.insert(pricebook, false); 
     String pricebookId = result.id; 
     List<PricebookEntry> fromStandardPricebook = [SELECT ID,Product2.ID,Product2.Name,Product2.Producer__c,Product2.Main_Image__c, Product2.Category__c, PricebookEntry.UnitPrice, IsDiscounted__c,PriceBeforeDiscount__c
     FROM PricebookEntry 
     WHERE Pricebook2.IsStandard = true];
     List<PricebookEntry> newPricebookEntryList = new List<PricebookEntry>();
           for(PricebookEntry pricebookEntry : fromStandardPricebook){
                PricebookEntry newPricebookEntry  = new PricebookEntry(
                     Product2Id = pricebookEntry.Product2.ID,
                     Pricebook2Id = pricebookId,
                     UnitPrice = pricebookEntry.PriceBeforeDiscount__c );
                     newPricebookEntryList.add(newPricebookEntry);
           } 
     insert newPricebookEntryList; 
     } 

    @AuraEnabled
    public static void updatePricebook(Pricebook2 pricebook, List<PricebookEntry> productList){  
         if(pricebook.IsActive){
          List<Pricebook2> pricebooks =  getPricebooks();
          for(Pricebook2 pb : pricebooks){
               if(pb.Id==pricebook.Id){
                pb.IsActive=true;
               }else{
                pb.IsActive=false;
               }
          }
          upsert pricebooks;
         }           
     upsert pricebook;
     upsert productList;    
     }   
}