public with sharing class CartController {
    public CartController() {

    }
    
    @AuraEnabled
    public static boolean addProductToCart(String id){
        Map<String,CartItem> cartItems = new Map<String,CartItem>();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.myCache');
        if((Map<String,CartItem>)sessionPart.get('cart')!=null)
        cartItems = (Map<String,CartItem>)sessionPart.get('cart');     
        CartItem cartItem = new CartItem();
        cartItem.productId = id;
        cartItem.product = getProductById(id);
        if(cartItems.isEmpty() || cartItems == null){
            cartItem.quantity = 1;
            cartItems.put(cartItem.productId, cartItem);           
        }else if(cartItems.keySet().contains(id)){
           CartItem tempItem = cartItems.get(id);
           tempItem.quantity++;
           cartItems.put(id,tempItem);                   
        }else{
            cartItem.quantity = 1;
            cartItems.put(id,cartItem);
        }              
        sessionPart.put('cart', cartItems);
        return true;
    }
        
    @AuraEnabled
    public static boolean deleteProductFromCart(String id){
        Map<String,CartItem> cartItems = new Map<String,CartItem>();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.myCache');
        if((Map<String,CartItem>)sessionPart.get('cart')!=null)
        cartItems = (Map<String,CartItem>)sessionPart.get('cart');                     
         if(cartItems.keySet().contains(id)){          
              cartItems.remove(id);  
          }  
        sessionPart.put('cart', cartItems);
        return true;
    }

    @AuraEnabled
    public static boolean decreaseProductFromCart(String id){
        Map<String,CartItem> cartItems = new Map<String,CartItem>();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.myCache');
        if((Map<String,CartItem>)sessionPart.get('cart')!=null)
        cartItems = (Map<String,CartItem>)sessionPart.get('cart');                     
         if(cartItems.keySet().contains(id)){          
            CartItem tempItem = cartItems.get(id);
            if(tempItem.quantity>1){
           --tempItem.quantity;
           
            }
            cartItems.put(id,tempItem);  
          }  
        sessionPart.put('cart', cartItems);
        return true;
    }

    @AuraEnabled
    public static boolean changeQuantity(String id, Integer quantity){
        Map<String,CartItem> cartItems = new Map<String,CartItem>();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.myCache');
        if((Map<String,CartItem>)sessionPart.get('cart')!=null)
        cartItems = (Map<String,CartItem>)sessionPart.get('cart');                     
         if(cartItems.keySet().contains(id)){          
            CartItem tempItem = cartItems.get(id);
            if(quantity>=1){          
                tempItem.quantity=quantity;           
            } else{
                tempItem.quantity=1;  
            }
            cartItems.put(id,tempItem);  
          }  
        sessionPart.put('cart', cartItems);
        return true;
    }
    
    @AuraEnabled
    public static boolean clearCart(){
        Map<String,CartItem> cartItems = new Map<String,CartItem>();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.myCache');
        if((Map<String,CartItem>)sessionPart.get('cart')!=null)
        cartItems = (Map<String,CartItem>)sessionPart.get('cart');  
        cartItems.clear(); 
        sessionPart.put('cart', cartItems);
        return true;
    }

    @AuraEnabled
    public static String getProductsFromCart(){      
        Map<String,CartItem> cartItemsMap = new Map<String,CartItem>();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.myCache');
        cartItemsmap = (Map<String,CartItem>)sessionPart.get('cart');  
        List<CartItem> cartItems = new List<CartItem>();
        cartItems = cartItemsMap.values();
        for(CartItem cartItem : cartItems){
            cartItem.isOne = cartItem.quantity<=1;
            cartItem.subtotal = cartItem.quantity * cartItem.product.UnitPrice;
            cartItemsmap.put(cartItem.productId,cartItem);
        }      
        sessionPart.put('cart', cartItemsMap);
        return JSON.serialize(cartItems);        
    }
    
    @AuraEnabled
    public static PricebookEntry getProductById(String productId) {      
        return [SELECT ID,Product2.ID,Product2.Name,Product2.Producer__c,Product2.Main_Image__c, Product2.Category__c, PricebookEntry.UnitPrice, IsDiscounted__c,PriceBeforeDiscount__c
        FROM PricebookEntry 
        WHERE Pricebook2.IsActive = true AND Product2.Id = :productId];    
    }   

    @AuraEnabled
    public static void  createOrder(){
        List<CartItem> cartItems = getCartItems();
        Pricebook2 pricebook = [SELECT ID,IsStandard FROM Pricebook2  WHERE Pricebook2.IsActive = true]; 
        Account account = [SELECT ID,Name FROM Account WHERE Name='DHL'];    
        Order order = new Order(AccountId = account.ID, Pricebook2Id=pricebook.ID, OwnerId=UserInfo.getUserId(),EffectiveDate=Date.today(),Status = 'Draft');      
        Database.SaveResult result = Database.insert(order, false);  
        String orderId = result.id;
        List<OrderItem> orderItems = new List<OrderItem>();   
        for(CartItem item : cartItems){
            OrderItem orderItem = new OrderItem(OrderId = orderId,PricebookEntryId = item.product.Id,UnitPrice=item.product.UnitPrice, Quantity=item.quantity);
            orderItems.add(orderItem);
        }
        insert orderItems;
    }

    public static List<CartItem>  getCartItems(){     
        Map<String,CartItem> cartItemsMap = new Map<String,CartItem>();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.myCache');
        cartItemsmap = (Map<String,CartItem>)sessionPart.get('cart');          
        return cartItemsMap.values();
    }
 
    public class CartItem {
        String productId;
        PricebookEntry product;
        Integer quantity;
        boolean isOne; 
        Decimal subtotal;           
    }
}