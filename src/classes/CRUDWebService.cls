global with sharing class CRUDWebService {

    webservice static String createMechanic(MechanicWrapper mechanicWrapper) {
        Mechanic__c mechanic = convertWrapperToMechanic(mechanicWrapper);
        Database.SaveResult result = Database.insert(mechanic, false);
        return result.success ? 'Success' : result.errors.get(0).message;
    }

    webservice static String deleteMechanic(String externalId) {
        Mechanic__c mechanic = [
                SELECT Id
                FROM Mechanic__c
                WHERE External_Id__c = :externalId
        ];
        Database.DeleteResult result = Database.delete(mechanic, false);
        return result.success ? 'Success' : result.errors.get(0).message;
    }

    webservice static String updateMechanic(String externalId, MechanicWrapper mechanicWrapper) {
        Mechanic__c mechanic = [
                SELECT Id
                FROM Mechanic__c
                WHERE External_Id__c = :externalId
        ];
        mechanic.First_Name__c = mechanicWrapper.firstName;
        mechanic.Name = mechanicWrapper.lastName;
        mechanic.Range__c = mechanicWrapper.level;
        mechanic.Email__c = mechanicWrapper.email;
        mechanic.Phone__c = mechanicWrapper.phone;
        mechanic.City__c = mechanicWrapper.city;
        mechanic.Street__c = mechanicWrapper.street;
        mechanic.Zip_Postal_Code__c = mechanicWrapper.postalCode;
        mechanic.Province__c = mechanicWrapper.province;
        mechanic.Country__c = mechanicWrapper.country;
        mechanic.Date_of_birth__c = mechanicWrapper.dateOfBirth != null
                ? Date.parse(mechanicWrapper.dateOfBirth) : null;
        Database.SaveResult result = Database.update(mechanic, false);
        return result.success ? 'Success' : result.errors.get(0).message;
    }

    webservice static MechanicWrapper readMechanic(String externalId) {
        Mechanic__c mechanic = [
                SELECT Id,External_Id__c,Name,First_name__c,Range__c,Email__c,Phone__c,
                        City__c,Street__c,Zip_Postal_Code__c,Province__c,Country__c,Date_of_birth__c
                FROM Mechanic__c
                WHERE External_Id__c = :externalId
        ];
        MechanicWrapper mechanicWrapper = convertMechanicToWrapper(mechanic);
        return mechanicWrapper;
    }

    webService static List<MechanicWrapper> mechanicsByQuery(String query) {
        List<Mechanic__c> mechanics = Database.query(query);
        List<MechanicWrapper> mechanicsWrappers = new List<MechanicWrapper>();
        for (Mechanic__c mechanic : mechanics) {
            mechanicsWrappers.add(convertMechanicToWrapper(mechanic));
        }
        return mechanicsWrappers;
    }

    public static Mechanic__c convertWrapperToMechanic(MechanicWrapper mechanicWrapper) {
        Mechanic__c mechanic = new Mechanic__c();
        mechanic.First_Name__c = mechanicWrapper.firstName;
        mechanic.Name = mechanicWrapper.lastName;
        mechanic.Range__c = mechanicWrapper.level;
        mechanic.Email__c = mechanicWrapper.email;
        mechanic.Phone__c = mechanicWrapper.phone;
        mechanic.City__c = mechanicWrapper.city;
        mechanic.Street__c = mechanicWrapper.street;
        mechanic.Zip_Postal_Code__c = mechanicWrapper.postalCode;
        mechanic.Province__c = mechanicWrapper.province;
        mechanic.Country__c = mechanicWrapper.country;
        mechanic.Date_of_birth__c = mechanicWrapper.dateOfBirth != null
                ? Date.parse(mechanicWrapper.dateOfBirth) : null;
        return mechanic;
    }

    public static MechanicWrapper convertMechanicToWrapper(Mechanic__c mechanic) {
        MechanicWrapper mechanicWrapper = new MechanicWrapper();
        mechanicWrapper.externalId = mechanic.External_Id__c;
        mechanicWrapper.id = mechanic.Id;
        mechanicWrapper.firstName = mechanic.First_Name__c;
        mechanicWrapper.lastName = mechanic.Name;
        mechanicWrapper.level = mechanic.Range__c;
        mechanicWrapper.email = mechanic.Email__c;
        mechanicWrapper.phone = mechanic.Phone__c;
        mechanicWrapper.city = mechanic.City__c;
        mechanicWrapper.street = mechanic.Street__c;
        mechanicWrapper.postalCode = mechanic.Zip_Postal_Code__c;
        mechanicWrapper.province = mechanic.Province__c;
        mechanicWrapper.country = mechanic.Country__c;
        mechanicWrapper.dateOfBirth = mechanic.Date_of_birth__c != null ? mechanic.Date_of_birth__c.format() : null;
        return mechanicWrapper;
    }

    global class MechanicWrapper {
        webservice String externalId { get; set; }
        webservice String id { get; set; }
        webservice String lastName { get; set; }
        webservice String firstName { get; set; }
        webservice String email { get; set; }
        webservice String phone { get; set; }
        webservice String city { get; set; }
        webservice String street { get; set; }
        webservice String postalCode { get; set; }
        webservice String province { get; set; }
        webservice String country { get; set; }
        webservice String dateOfBirth { get; set; }
        webservice String backMessage { get; set; }
        webservice String level { get; set; }
    }
}