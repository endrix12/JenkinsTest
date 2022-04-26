public without sharing class PublicPageController {

    public List<Mechanic__c> mechanicsList { get; set; }

    public PublicPageController() {
        this.mechanicsList = getRandomMechanics();
    }

    public List<Mechanic__c> getRandomMechanics() {
        Integer amountMechanicsToRand = 5;
        Integer count = [
                SELECT COUNT()
                FROM Mechanic__c
        ];
        Integer rand = count > amountMechanicsToRand
                ? Math.floor(Math.random() * (count - amountMechanicsToRand + 1)).intValue()
                : 0;
        return [
                SELECT Id,First_name__c,Name,Email__c,City__c,Country__c
                FROM Mechanic__c
                LIMIT :amountMechanicsToRand
                OFFSET :rand
        ];
    }
}