public class SearchController {

    public Mechanic__c searchMechanic { get; set; }
    public List<Mechanic__c> mechanicsList { get; set; }
    public List<Mechanic__c> mechanicsListToFile { get; set; }
    public List<Mechanic__c> mechanicsTemp { get; set; }

    List<string> conditions = new List<string>();
    private Integer totalRecords = 0;
    private Integer OffsetSize = 0;
    public Integer limitSize = 10;
    private String pageSize = '10';
    private String headersCSV = 'First Name;Last Name;Email;City;Country';
    private String headersXLS = 'First Name\tLast Name\tEmail\tCity\tCountry';

    public String getHeadersCSV() {
        return headersCSV;
    }

    public String getHeadersXLS() {
        return headersXLS;
    }

    public String getBreakLine() {
        return '\n';
    }

    public String getTabChar() {
        return '\t';
    }

    public SearchController() {
        searchMechanic = new Mechanic__c();
        mechanicsList = new List<Mechanic__c>();
        mechanicsListToFile = new List<Mechanic__c>();
        mechanicsTemp = new List<Mechanic__c>();
    }

    public void reloadPageSize() {
        if (totalRecords != 0) {
            searchMechanicsAction();
        }
    }

    public void searchMechanicsAction() {
        totalRecords = 0;
        OffsetSize = 0;
        limitSize = Integer.valueOf(this.pageSize);
        if (mechanicsList != null && mechanicsList.size() > 0) {
            mechanicsList = null;
        }
        searchMechanics();
        conditions.clear();
    }

    public void clearSearchField() {
        searchMechanic.clear();
        conditions.clear();
        mechanicsList.clear();
        totalRecords = 0;
        OffsetSize = 0;
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

    public List<Mechanic__c> searchMechanics() {
        if (mechanicsList != null && !mechanicsList.isEmpty()) {
            mechanicsList.clear();
        }
        String strQuery = 'SELECT First_name__c, Name, Email__c, City__c, Country__c FROM Mechanic__c';
        if (searchMechanic.First_name__c != null) {
            conditions.add('First_name__c Like \'%' + String.escapeSingleQuotes(searchMechanic.First_name__c) + '%\' ');
        }

        if (searchMechanic.Name != null) {
            conditions.add('Name Like \'%' + String.escapeSingleQuotes(searchMechanic.Name) + '%\' ');
        }

        if (!(searchMechanic.Email__c == null || searchMechanic.Email__c == '')) {
            conditions.add('Email__c Like \'%' + String.escapeSingleQuotes(searchMechanic.Email__c) + '%\' ');
        }

        if (searchMechanic.Country__c != null) {
            conditions.add('Country__c Like \'%' + String.escapeSingleQuotes(searchMechanic.Country__c) + '%\' ');
        }

        if (conditions.size() > 0) {
            strQuery += '  WHERE ' + conditions[0];
            for (Integer i = 1; i < conditions.size(); i++) {
                strQuery += '  AND ' + conditions[i];
            }
        }
        if (totalRecords != null && totalRecords == 0) {
            mechanicsTemp = Database.query(strQuery);
            totalRecords = (mechanicsTemp != null && mechanicsTemp.size() > 0) ? mechanicsTemp.size() : 0;
        }
        String strQueryToFile = strQuery;
        strQuery += ' ORDER BY Name LIMIT ' + limitSize + ' OFFSET ' + OffsetSize;
        strQueryToFile += ' ORDER BY Name ';

        mechanicsList = Database.query(strQuery);
        mechanicsListToFile = Database.query(strQueryToFile);
        conditions.clear();
        return mechanicsList;
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
        searchMechanics();
    }

    public void previous() {
        OffsetSize = (OffsetSize - limitSize);
        searchMechanics();
    }

    public void next() {
        OffsetSize += limitSize;
        searchMechanics();
    }

    public void lastPage() {
        OffsetSize = totalRecords - math.mod(totalRecords, LimitSize);
        searchMechanics();
    }

    public boolean getprev() {
        return (OffsetSize == 0);
    }

    public boolean getnxt() {
        return ((OffsetSize + limitSize) >= totalRecords);
    }

    public PageReference exportToCSV() {
        PageReference reRend = new PageReference('/apex/MechanicsCSV');
        return reRend;
    }

    public PageReference exportToXLS() {
        PageReference reRend = new PageReference('/apex/MechanicsXLS');
        return reRend;
    }

    public boolean getIsResult() {
        return (totalRecords == 0);
    }
}