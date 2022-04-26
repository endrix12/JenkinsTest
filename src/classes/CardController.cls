public with sharing class CardController {

    @AuraEnabled
    public static Contact getContactById(String contactId) {
        Contact contact = Database.query('SELECT Id,FirstName,LastName,Title,Email,Phone,' +
                'MailingStreet,MailingCity,MailingPostalCode,MailingCountry ' +
                'FROM Contact ' +
                'WHERE Id=\'' + contactId +'\'');
        return contact;
    }

}