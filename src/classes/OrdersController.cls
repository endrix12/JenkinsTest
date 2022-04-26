public with sharing class OrdersController {
    public OrdersController() {

    }

    @AuraEnabled
    public static List<Order> getOrders(){     
         return [SELECT ID ,Name,EffectiveDate,OrderNumber,TotalAmount 
                FROM Order 
                WHERE CreatedById = :UserInfo.getUserId() ORDER BY OrderNumber DESC];
    }

    @AuraEnabled
    public static List<OrderItem> getOrderItems(String orderId){     
         return [SELECT ID, Quantity, Product2.Main_Image__c, Product2.Name, Product2.Producer__c, UnitPrice, TotalPrice
                FROM OrderItem 
                WHERE OrderId =: orderId];
    }

    @AuraEnabled
    public static Boolean isPurchased(String productId){     
         return [SELECT  COUNT()
                FROM OrderItem 
                WHERE CreatedById = :UserInfo.getUserId() AND Product2Id=:productId]>0;
    }

}