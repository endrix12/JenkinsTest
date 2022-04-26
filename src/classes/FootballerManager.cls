@RestResource(urlMapping='/Footballer/*')
global with sharing class FootballerManager {

    @HttpPost
    global static List<Result> insertFootballer(List<FootballerWrapper> footballerWrappers) {
        triggerSwitcherOff();
        List<Database.SaveResult> resultsDb =
                Database.insert(footballerWrappersListToFootballersList(footballerWrappers), false);
        triggerSwitcherOn();
        return createResults(resultsDb, footballerWrappers);
    }

    @HttpPut
    global static List<Result> updateFootballer(List<FootballerWrapper> footballerWrappers) {
        triggerSwitcherOff();
        List<Database.SaveResult> resultsDb =
                Database.update(footballerWrappersListToFootballersList(footballerWrappers), false);
        triggerSwitcherOn();
        return createResults(resultsDb, footballerWrappers);
    }

    @HttpDelete
    global static List<Result> deleteFootballer() {
        List<FootballerWrapper> footballerWrappers = getFootballerWrappersFromRestRequest(RestContext.request);
        List<String> ids = getExternalIdsFromFootballerWrappers(footballerWrappers);
        List<Footballer__c> footballersList = Database.query('SELECT Name FROM Footballer__c WHERE Id IN :ids');
        triggerSwitcherOff();
        List<Database.DeleteResult> deleteResults = Database.delete(footballersList, false);
        triggerSwitcherOn();
        return createDeleteResults(deleteResults, footballerWrappers);
    }

    private static void triggerSwitcherOff() {
        TriggerSwitcher__c triggerSwitcher = TriggerSwitcher__c.getValues('FootballersTrigger');
        triggerSwitcher.run__c = false;
        update triggerSwitcher;
    }

    private static void triggerSwitcherOn() {
        TriggerSwitcher__c triggerSwitcher = TriggerSwitcher__c.getValues('FootballersTrigger');
        triggerSwitcher.run__c = true;
        update triggerSwitcher;
    }

    private static List<String> getExternalIdsFromFootballerWrappers(List<FootballerWrapper> footballerWrappers) {
        List<String> ids = new List<String>();
        for (FootballerWrapper footballerWrapper : footballerWrappers) {
            ids.add(footballerWrapper.externalId);
        }
        return ids;
    }

    private static List<FootballerWrapper> getFootballerWrappersFromRestRequest(RestRequest restRequest) {
        Blob requestBlob = restRequest.requestBody;
        String requestBody = requestBlob.toString();
        Request request = (Request) JSON.deserialize(requestBody, Request.class);
        return request.footballerWrappers;
    }

    private static List<Result> createResults(List<Database.SaveResult> resultsDb,
            List<FootballerWrapper> footballerWrappers) {
        List<Result> results = new List<Result>();
        for (Integer i = 0; i < resultsDb.size(); i++) {
            String message;
            footballerWrappers.get(i).externalId = resultsDb.get(i).id;
            if (resultsDb.get(i).success) {
                message = 'Success';
            } else {
                message = resultsDb.get(i).errors.get(0).message;
            }
            results.add(new Result(
                    resultsDb.get(i).success,
                    footballerWrappers.get(i),
                    message, Date.today().format(),
                    UserInfo.getName()));
        }
        return results;
    }

    private static List<Result> createDeleteResults(List<Database.DeleteResult> resultsDb,
            List<FootballerWrapper> footballerWrappers) {
        List<Result> results = new List<Result>();
        for (Integer i = 0; i < resultsDb.size(); i++) {
            String message;
            if (resultsDb.get(i).success) {
                message = 'Success';
            } else {
                message = resultsDb.get(i).errors.get(0).message;
            }
            results.add(new Result(resultsDb.get(i).success,
                    footballerWrappers.get(i),
                    message, Date.today().format(),
                    UserInfo.getName()));
        }
        return results;
    }

    public static Footballer__c wrapperToFootballer(FootballerWrapper footballerWrapper) {
        return new Footballer__c(
                ExternalId__c = footballerWrapper.id,
                Id = footballerWrapper.externalId,
                Name = footballerWrapper.lastName,
                FirstName__c = footballerWrapper.firstName,
                Birthday__c = footballerWrapper.birthday != null ? Date.parse(footballerWrapper.birthday) : null,
                Country__c = footballerWrapper.country,
                Team__c = footballerWrapper.team,
                Synchronized__c = true,
                SynchroAttempt__c = footballerWrapper.synchronizationCounter
        );
    }

    public static List<Footballer__c> footballerWrappersListToFootballersList(List<FootballerWrapper> footballerWrappers) {
        List<Footballer__c> footballers = new List<Footballer__c>();
        List<Result> results = new List<Result>();
        for (FootballerWrapper footballerWrapper : footballerWrappers) {
            Footballer__c newFootballer = wrapperToFootballer(footballerWrapper);
            footballers.add(newFootballer);
        }
        return footballers;
    }

    public static FootballerWrapper footballerToWrapper(Footballer__c footballer) {
        FootballerWrapper footballerWrapper = new FootballerWrapper();
        footballerWrapper.id = footballer.Id;
        footballerWrapper.externalId = footballer.ExternalId__c;
        footballerWrapper.lastName = footballer.Name;
        footballerWrapper.firstName = footballer.FirstName__c;
        footballerWrapper.birthday = footballer.Birthday__c != null ? footballer.Birthday__c.format() : null;
        footballerWrapper.country = footballer.Country__c;
        footballerWrapper.team = footballer.Team__c;
        footballerWrapper.isSynchronized = footballer.Synchronized__c;
        footballerWrapper.synchronizationCounter = (Integer) footballer.SynchroAttempt__c;
        return footballerWrapper;
    }

    global class FootballerWrapper {
        global String id;
        global String externalId;
        global String lastName;
        global String firstName;
        global String birthday;
        global String country;
        global String team;
        global Boolean isSynchronized;
        global Integer synchronizationCounter;
    }

    global class Result {
        global Boolean success;
        global FootballerWrapper footballerWrapper;
        global String message;
        global String resultDate;
        global String user;

        public Result(Boolean isSuccess, FootballerWrapper footballerWrapper, String message, String resultDate, String user) {
            this.success = isSuccess;
            this.footballerWrapper = footballerWrapper;
            this.message = message;
            this.resultDate = resultDate;
            this.user = user;
        }
        public Result() {
        }
    }

    global class Request {
        global List<FootballerWrapper> footballerWrappers;
    }
}