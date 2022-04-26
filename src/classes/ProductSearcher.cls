public with sharing class ProductSearcher {
    public ProductSearcher() {

    }

    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getProducts(String productName, String productCategory){
        String searchName= '%'+ productName + '%';
        String searchCategory= '%'+ productCategory + '%';
            return [SELECT ID,Product2.ID,Product2.Name,Product2.Producer__c,Product2.Main_Image__c, Product2.Category__c,Pricebook2.IsActive, PricebookEntry.UnitPrice, IsDiscounted__c,PriceBeforeDiscount__c
                FROM PricebookEntry 
                WHERE Pricebook2.IsActive= true AND Product2.Name LIKE :searchName AND Product2.Category__c LIKE :searchCategory];
    }

    @AuraEnabled(cacheable=true)
    public static PricebookEntry getPriceById(String productId){       
        return [SELECT ID,Product2.ID,Product2.Name,Product2.Producer__c,Product2.Main_Image__c, Product2.Category__c,Pricebook2.IsActive, PricebookEntry.UnitPrice, IsDiscounted__c,PriceBeforeDiscount__c
                FROM PricebookEntry 
                WHERE Pricebook2.IsActive = true AND Product2.Id =:productId];
    }
}