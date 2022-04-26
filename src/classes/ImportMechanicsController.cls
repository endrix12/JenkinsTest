public with sharing class ImportMechanicsController {

    public Map<String, MechanicWrapper> mechanicsByGUID { get; set; }
    public transient Blob csvFileBody { get; set; }
    public string csvAsString { get; set; }
    public String[] csvFileLines { get; set; }
    public List<MechanicWrapper> mechanics { get; set; }
    public String delimiter { get; set; }
    public String[] csvHeaders { get; set; }

    public ImportMechanicsController() {
        csvFileLines = new String[]{
        };
        mechanics = new List<MechanicWrapper>();
        delimiter = ',';
    }

    public void clearAll() {
        mechanics = new List<MechanicWrapper>();
    }

    public String assignFieldValue(String valueFromHeader, List<String> csvHeaders, String[] csvRecordData) {
        return csvHeaders.indexOf(valueFromHeader) < csvRecordData.size()
                && csvHeaders.indexOf(valueFromHeader) != -1
                ? csvRecordData[csvHeaders.indexOf(valueFromHeader)] : null;
    }

    public void importCSVFile() {
        try {
            mechanics = new List<MechanicWrapper>();
            csvAsString = csvFileBody.toString();
            csvFileLines = csvAsString.split('\n');
            csvHeaders = csvFileLines.get(0).split(delimiter);
            for (Integer i = 1; i < csvFileLines.size(); i++) {
                MechanicWrapper mechanicWrapper = new MechanicWrapper() ;
                String[] csvRecordData = csvFileLines[i].split(delimiter);
                mechanicWrapper.firstName = assignFieldValue('First Name', csvHeaders, csvRecordData);
                mechanicWrapper.lastName = assignFieldValue('Last Name', csvHeaders, csvRecordData);
                mechanicWrapper.level = assignFieldValue('Level', csvHeaders, csvRecordData);
                mechanicWrapper.email = assignFieldValue('Email', csvHeaders, csvRecordData);
                mechanicWrapper.phone = assignFieldValue('Phone', csvHeaders, csvRecordData);
                mechanicWrapper.city = assignFieldValue('City', csvHeaders, csvRecordData);
                mechanicWrapper.street = assignFieldValue('Street', csvHeaders, csvRecordData);
                mechanicWrapper.postalCode = assignFieldValue('Postal Code', csvHeaders, csvRecordData);
                mechanicWrapper.province = assignFieldValue('Province', csvHeaders, csvRecordData);
                mechanicWrapper.country = assignFieldValue('Country', csvHeaders, csvRecordData);
                mechanicWrapper.dateOfBirth = assignFieldValue('Date Of Birth', csvHeaders, csvRecordData);
                mechanicWrapper.isChecked = false;
                mechanics.add(mechanicWrapper);
            }

        } catch (Exception e) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, Label.ImportCSVFileError);
            ApexPages.addMessage(errorMessage);
        }
    }

    public void insertAll() {
        List<MechanicWrapper> selectedMechanics = retrieveSelectedMechanicsData(mechanics);
        checkMechanics(selectedMechanics);
        List<Mechanic__c> mechanicsToImport = convertWrapperToMechanic(selectedMechanics);
        checkMechanics(mechanicsToImport);
        List<Database.SaveResult> results = Database.insert(mechanicsToImport, false);
        Map<String, MechanicWrapper> mechanicsByGUID;
        Integer counter = 0;



        for (Database.SaveResult result : results) {
            if (result.success) {
                selectedMechanics.get(counter).backMessage = System.Label.Success;
                selectedMechanics.get(counter).id = result.getId();

            } else if (!result.success) {
                selectedMechanics.get(counter).backMessage = result.getErrors().get(0).message;
            }
            counter++;
        }
        mechanicsByGUID = convertMechanicsToGUIDMap(selectedMechanics);
        for (MechanicWrapper mechanic : mechanics) {
            if (mechanicsByGUID.containsKey(mechanic.GUID)) {
                mechanic = mechanicsByGUID.get(mechanic.GUID);
            }
        }
        checkMechanics(mechanics);
    }

    public void checkMechanics(List<Mechanic__c> mechanics) {
        for (Integer i = 0; i < mechanics.size() - 1; i++) {
            for (Integer j = i + 1; j < mechanics.size(); j++) {
                if (mechanics.get(i).Name == mechanics.get(j).Name && mechanics.get(i).First_name__c == mechanics.get(j).First_name__c) {
                    mechanics.remove(i);
                }
            }
        }
    }

    public void checkMechanics(List<MechanicWrapper> mechanics) {

        for (Integer i = 0; i < mechanics.size() - 1; i++) {
            for (Integer j = i + 1; j < mechanics.size(); j++) {
                if (mechanics.get(i).lastName == mechanics.get(j).lastName && mechanics.get(i).firstName == mechanics.get(j).firstName) {
                    mechanics.get(j).backMessage = System.Label.DuplicatedInFile;
                }
            }
        }
    }

    public List<Mechanic__c> convertWrapperToMechanic(List<MechanicWrapper> mechanicData) {
        List<Mechanic__c> selectedMechanics = new List<Mechanic__c>();
        for (MechanicWrapper mechanic : mechanicData) {
            Mechanic__c selectedMechanic = new Mechanic__c();
            selectedMechanic.First_Name__c = mechanic.firstName;
            selectedMechanic.Name = mechanic.lastName;
            selectedMechanic.Range__c = mechanic.level;
            selectedMechanic.Email__c = mechanic.email;
            selectedMechanic.Phone__c = mechanic.phone;
            selectedMechanic.City__c = mechanic.city;
            selectedMechanic.Street__c = mechanic.street;
            selectedMechanic.Zip_Postal_Code__c = mechanic.postalCode;
            selectedMechanic.Province__c = mechanic.province;
            selectedMechanic.Country__c = mechanic.country;
            selectedMechanic.Date_of_birth__c = mechanic.dateOfBirth != null ? Date.valueOf(mechanic.dateOfBirth) : null;
            selectedMechanics.add(selectedMechanic);
        }
        return selectedMechanics;
    }

    public List<MechanicWrapper> retrieveSelectedMechanicsData(List<MechanicWrapper> mechanicData) {
        List<MechanicWrapper> selectedMechanicsData = new List<MechanicWrapper>();
        for (MechanicWrapper mechanic : mechanicData) {
            if (mechanic.isChecked) {
                selectedMechanicsData.add(mechanic);
            }
        }
        return selectedMechanicsData;
    }

    public Map<String, MechanicWrapper> convertMechanicsToGUIDMap(List<MechanicWrapper> mechanics) {
        Map<String, MechanicWrapper> mechanicsByGUID = new Map<String, MechanicWrapper>();
        for (MechanicWrapper mechanic : mechanics) {
            mechanicsByGUID.put(mechanic.GUID, mechanic);
        }
        return mechanicsByGUID;
    }

    public void selectAll() {
        for (MechanicWrapper mechanicWrapper : mechanics) {
            mechanicWrapper.isChecked = true;
        }
    }

    public void deSelectAll() {
        for (MechanicWrapper mechanicWrapper : mechanics) {
            mechanicWrapper.isChecked = false;
        }
    }

    public void invertAll() {
        for (MechanicWrapper mechanicWrapper : mechanics) {
            mechanicWrapper.isChecked = !mechanicWrapper.isChecked;
        }
    }

    public class MechanicWrapper {
        public String GUID { get; set; }
        public String lastName { get; set; }
        public String firstName { get; set; }
        public String email { get; set; }
        public String phone { get; set; }
        public String city { get; set; }
        public String street { get; set; }
        public String postalCode { get; set; }
        public String province { get; set; }
        public String country { get; set; }
        public String dateOfBirth { get; set; }
        public Boolean isChecked { get; set; }
        public String backMessage { get; set; }
        public String level { get; set; }
        public String id { get; set; }
        public MechanicWrapper() {
            this.GUID = GUIDGenertor();
        }
        private String GUIDGenertor() {
            List<integer> guidASCIICode = new List<integer>();
            while (guidASCIICode.size() < 32) {
                double rnd = Math.random();
                integer alphanumeric = (integer) (rnd * 22);
                alphanumeric += 48;
                if (alphanumeric < 58 || alphanumeric > 65) {
                    guidASCIICode.Add(alphanumeric);
                }
            }
            return String.fromCharArray(guidASCIICode);
        }
    }
}