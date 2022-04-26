public with sharing class ProductController {
    public ProductController() {

    }

    @AuraEnabled
    public static Product2 upsertProduct(Product2 product){
        system.debug(product);
        try {
            Database.UpsertResult result = Database.upsert(product, false);
            List<Pricebook2> allPricebooks = PricebookController.getPricebooks();
            List<PricebookEntry> pricebookEntryList = new List <PricebookEntry>();
            for(Pricebook2 pricebook : allPricebooks){
                PricebookEntry pricebookEntry = new PricebookEntry(UnitPrice = product.Price__c,Pricebook2Id=pricebook.ID,Product2Id=result.ID);
                pricebookEntryList.add(pricebookEntry);
            }
            upsert pricebookEntryList;
            return [SELECT ID ,Name, Producer__c, Price__c, Main_Image__c 
            FROM Product2 WHERE ID =:result.Id LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<String> getAddedImages(String productId) {
         List<String> idsList = new List<String>();
         List<ContentDocumentLink> contentDocumentLinks = [
            SELECT contentdocumentid
            FROM ContentDocumentLink
            WHERE linkedentityid = :productId
            ];

         for (ContentDocumentLink cdl : contentDocumentLinks) {
            idsList.add('/sfc/servlet.shepherd/document/download/'+cdl.ContentDocumentId);
         }
    return idsList;
    }   

    @AuraEnabled
    public static Product2 updateProduct(Product2 product){
        Database.UpsertResult result = Database.upsert(product, false);
        return [SELECT ID ,Name, Producer__c, Price__c, Main_Image__c 
        FROM Product2 WHERE ID =:result.Id LIMIT 1];
    }

}