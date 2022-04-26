global with sharing class SearchDoctorsController {

    public String doctorByExternalId { get; set; }
    public Boolean showDeleteModal { get; set; }
    public Boolean showNewModal { get; set; }
    public Boolean showEditModal { get; set; }
    public Boolean showModal { get; set; }
    public String modalHeader { get; set; }
    public String result { get; set; }
    public DoctorWrapper doctorWrapper { get; set; }
    public Mechanic__c searchDoctor { get; set; }
    public List<DoctorWrapper> doctorsList { get; set; }
    public List<soapSforceComSchemasClassDoctorserv.DoctorWrapper> doctorsTemp { get; set; }

    private soapSforceComSchemasClassDoctorserv.DoctorService service;
    private soapSforceComSchemasClassDoctorserv.SessionHeader_element sessionHeader;
    private partnerSoapSforceCom.LoginResult loginResult;
    private partnerSoapSforceCom.Soap partnerSoap;
    private String user = (String) Login__mdt.getAll().get('DoctorsAPI').get('Login__c');
    private String password = (String) Login__mdt.getAll().get('DoctorsAPI').get('Password__c');
    private Cache.OrgPartition orgPart = Cache.Org.getPartition('local.myCache');

    List<string> conditions = new List<string>();
    private Integer totalRecords = 0;
    private Integer OffsetSize = 0;
    public Integer limitSize = 10;
    private String pageSize = '10';

    public SearchDoctorsController() {
        doctorWrapper = new DoctorWrapper();
        this.service = new soapSforceComSchemasClassDoctorserv.DoctorService();
        this.sessionHeader = new soapSforceComSchemasClassDoctorserv.SessionHeader_element();
        this.partnerSoap = new partnerSoapSforceCom.Soap();

        String sessionIdFromCache = (String) orgPart.get('sessionId');
        if (sessionIdFromCache != null) {
            try {
                this.SessionHeader.sessionId = sessionIdFromCache;
                this.service.SessionHeader = sessionHeader;
            } catch (Exception e) {
                login();
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Session has expired. Logged in again'));
            }
        } else {

            login();
        }
        searchDoctor = new Mechanic__c();
        doctorsList = new List<DoctorWrapper>();
        doctorsTemp = new List<soapSforceComSchemasClassDoctorserv.DoctorWrapper>();
    }

    public void login() {
        loginResult = partnerSoap.login(user, password);
        String sessionId = loginResult.sessionId;
        sessionHeader.sessionId = sessionId;
        service.SessionHeader = sessionHeader;
        orgPart.put('sessionId', sessionId);
        sendEmail(sessionId);
    }

    public void reloadPageSize() {
        if (totalRecords != 0) {
            searchDoctorsAction();
        }
    }

    public void searchDoctorsAction() {
        totalRecords = 0;
        OffsetSize = 0;
        limitSize = Integer.valueOf(this.pageSize);
        if (doctorsList != null && doctorsList.size() > 0) {
            doctorsList.clear();
        }
        searchDoctors();
        conditions.clear();
    }

    public void clearSearchField() {
        searchDoctor.clear();
        conditions.clear();
        doctorsList.clear();
        totalRecords = 0;
        OffsetSize = 0;
    }

    public void showNewModal() {
        doctorWrapper = new doctorWrapper();
    }

    public void showEditModal() {
        doctorWrapper = doctorToWrapper(service.selectDoctor(doctorByExternalId));
    }

    public void deleteDoctor() {
        service.deleteDoctor(doctorByExternalId);
        searchDoctorsAction();
    }

    public void editDoctor() {
        if (doctorWrapper.lastName == '' || doctorWrapper.email == '') {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Last Name and Email can\'t be empty'));
            searchDoctorsAction();
        } else {
            try {
                String result = service.updateDoctor(doctorByExternalId, wrapperToDoctor(doctorWrapper));
                searchDoctorsAction();
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Edited operation completed successfully'));
            } catch (Exception e) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            }
        }
    }

    public void createDoctor() {

        if (doctorWrapper.lastName == '' || doctorWrapper.email == '') {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Last Name and Email can\'t be empty'));

            searchDoctorsAction();
        } else {
            try {
                String result = service.insertDoctor(wrapperToDoctor(doctorWrapper));
                searchDoctorsAction();
                searchDoctor.clear();
                doctorWrapper = new DoctorWrapper();
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Created operation completed successfully'));

            } catch (Exception e) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            }
        }
    }

    public Integer getTotalRecords() {
        return totalRecords;
    }

    public Integer getOffsetSize() {
        return (totalRecords == 0 ? 0 : OffsetSize / limitSize + 1);
    }

    public Integer getPageNumber() {
        if (math.mod(totalRecords, limitSize) == 0) {
            return totalRecords / limitSize;
        } else {
            return totalRecords / limitSize + 1;
        }
    }

    public List<DoctorWrapper> searchDoctors() {
        if (doctorsList != null && !doctorsList.isEmpty()) {
            doctorsList.clear();
        }
        String strQuery = 'SELECT SoapExternalId__c, Id, First_name__c, Name, Email__c, City__c, Country__c,' +
                'Date_of_birth__c, Medical_field__c, Phone_number__c,Postcode__c,Salary__c,Street__c,Ward__c' +
                ' FROM Doctor__c ';
        if (searchDoctor.First_name__c != null) {
            conditions.add('First_name__c Like \'%' + String.escapeSingleQuotes(searchDoctor.First_name__c) + '%\' ');
        }

        if (searchDoctor.Name != null) {
            conditions.add('Name Like \'%' + String.escapeSingleQuotes(searchDoctor.Name) + '%\' ');
        }

        if (!(searchDoctor.Email__c == null || searchDoctor.Email__c == '')) {
            conditions.add('Email__c Like \'%' + String.escapeSingleQuotes(searchDoctor.Email__c) + '%\' ');
        }

        if (searchDoctor.Country__c != null) {
            conditions.add('Country__c Like \'%' + String.escapeSingleQuotes(searchDoctor.Country__c) + '%\' ');
        }

        if (conditions.size() > 0) {
            strQuery += '  WHERE ' + conditions[0];
            for (Integer i = 1; i < conditions.size(); i++) {
                strQuery += '  AND ' + conditions[i];
            }
        }
        if (totalRecords != null && totalRecords == 0) {
            doctorsTemp = service.doctorQuery(strQuery);
            totalRecords = (doctorsTemp != null && doctorsTemp.size() > 0) ? doctorsTemp.size() : 0;
        }
        String strQueryToFile = strQuery;
        strQuery += ' ORDER BY Name LIMIT ' + limitSize + ' OFFSET ' + OffsetSize;

        List<soapSforceComSchemasClassDoctorserv.DoctorWrapper> doctorList = service.doctorQuery(strQuery);
        if (doctorList == null) {
            return new List<DoctorWrapper>();
        }
        for (soapSforceComSchemasClassDoctorserv.DoctorWrapper doctor : doctorList) {
            doctorsList.add(doctorToWrapper(doctor));
        }

        conditions.clear();
        return doctorsList;
    }

    public List<SelectOption> getPageSizeItems() {
        List<SelectOption> pageSizeItems = new List<SelectOption>();
        pageSizeItems.add(new SelectOption('1', '1'));
        pageSizeItems.add(new SelectOption('2', '2'));
        pageSizeItems.add(new SelectOption('5', '5'));
        pageSizeItems.add(new SelectOption('10', '10'));
        pageSizeItems.add(new SelectOption('15', '15'));
        pageSizeItems.add(new SelectOption('20', '20'));
        pageSizeItems.add(new SelectOption('25', '25'));
        pageSizeItems.add(new SelectOption('30', '30'));
        pageSizeItems.add(new SelectOption('35', '35'));
        pageSizeItems.add(new SelectOption('40', '40'));
        pageSizeItems.add(new SelectOption('50', '50'));
        pageSizeItems.add(new SelectOption('100', '100'));
        return pageSizeItems;
    }

    public String getPageSize() {
        return pageSize;
    }

    public void setPageSize(String pageSize) {
        this.pageSize = pageSize;
    }

    public void firstPage() {
        OffsetSize = 0;
        searchDoctors();
    }

    public void previous() {
        OffsetSize = (OffsetSize - limitSize);
        searchDoctors();
    }

    public void next() {
        OffsetSize += limitSize;
        searchDoctors();
    }

    public void lastPage() {
        OffsetSize = totalRecords - math.mod(totalRecords, LimitSize);
        searchDoctors();
    }

    public boolean getprev() {
        return (OffsetSize == 0);
    }

    public boolean getnxt() {
        return ((OffsetSize + limitSize) >= totalRecords);
    }

    public boolean getIsResult() {
        return (totalRecords == 0);
    }

    public static void sendEmail(String sessionId) {
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{
                'andrzejbusko610@gmail.com'
        };
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('newSessionId');
        mail.setSubject('newSessionId');
        mail.setBccSender(false);
        mail.setPlainTextBody('Your new sessionId: ' + sessionId);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });
    }

    public static DoctorWrapper doctorToWrapper(soapSforceComSchemasClassDoctorserv.DoctorWrapper doctor) {
        DoctorWrapper doctorWrapper = new DoctorWrapper();
        doctorWrapper.SoapExternalId = doctor.SoapExternalId;
        doctorWrapper.Id = doctor.Id;
        doctorWrapper.lastName = doctor.lastName;
        doctorWrapper.firstName = doctor.firstName;
        doctorWrapper.email = doctor.email;
        doctorWrapper.city = doctor.city;
        doctorWrapper.doctorCountry = doctor.doctorCountry;
        doctorWrapper.dateOfBirth = doctor.dateOfBirth;
        doctorWrapper.medicalField = doctor.medicalField ;
        doctorWrapper.phoneNumber = doctor.phoneNumber;
        doctorWrapper.postcode = doctor.postcode;
        doctorWrapper.salary = doctor.salary;
        doctorWrapper.street = doctor.street;
        doctorWrapper.ward = doctor.ward;
        return doctorWrapper;
    }

    public static soapSforceComSchemasClassDoctorserv.DoctorWrapper wrapperToDoctor(DoctorWrapper doctorWrapper) {
        soapSforceComSchemasClassDoctorserv.DoctorWrapper doctor = new soapSforceComSchemasClassDoctorserv.DoctorWrapper();
        doctor.lastName = doctorWrapper.lastName;
        doctor.firstName = doctorWrapper.firstName;
        doctor.email = doctorWrapper.email;
        doctor.city = doctorWrapper.city;
        doctor.doctorCountry = doctorWrapper.doctorCountry;
        doctor.dateOfBirth = doctorWrapper.dateOfBirth;
        doctor.medicalField = doctorWrapper.medicalField;
        doctor.phoneNumber = doctorWrapper.phoneNumber;
        doctor.postcode = doctorWrapper.postcode;
        doctor.salary = doctorWrapper.salary;
        doctor.street = doctorWrapper.street;
        doctor.ward = doctorWrapper.ward;
        return doctor;
    }

    global class DoctorWrapper {
        webservice String SoapExternalId {
            get;
            set;
        }
        webservice String Id {
            get;
            set;
        }
        webservice String lastName {
            get;
            set;
        }
        webservice String firstName { get; set; }
        webservice String email {
            get;
            set;
        }
        webservice String city {
            get;
            set;
        }
        webservice String doctorCountry {
            get;
            set;
        }
        webservice String dateOfBirth {
            get;
            set;
        }
        webservice String medicalField {
            get;
            set;
        }
        webservice String phoneNumber {
            get;
            set;
        }
        webservice String postcode {
            get;
            set;
        }
        webservice Decimal salary {
            get;
            set;
        }
        webservice String street {
            get;
            set;
        }
        webservice String ward {
            get;
            set;
        }
    }
}