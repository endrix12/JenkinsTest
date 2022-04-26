public with sharing class SearchAccountController {

    @AuraEnabled
    public static List<Account> getAccountByName(String searchingAccountName) {
       List<Account> accounts = Database.query('SELECT Id,Name,Phone,Website,BillingCountry,BillingCity,BillingStreet ' +
               'FROM Account ' +
               'WHERE Name ' +
               'LIKE \'%' + searchingAccountName + '%\'');

        return accounts;
    }

    @AuraEnabled
    public static List <Account> getAccountById(String accountId) {
        List <Account> accounts = Database.query('SELECT Id,Name,Phone,Website,BillingCountry,BillingCity,BillingStreet ' +
                'FROM Account ' +
                'WHERE Id=\'' + accountId+'\'');
        System.debug(accounts);
        return accounts;
    }


}