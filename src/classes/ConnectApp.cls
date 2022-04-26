public with sharing class ConnectApp {

    private static final String REST_ENDPOINT = 'callout:FootballerCallout';

    public static void makeConnectCallout() {
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:Connect');
            request.setMethod('POST');
            REST_Credentials__c credentials = REST_Credentials__c.getOrgDefaults();
            String body = 'grant_type=password&' +
                    'client_id=' + credentials.ClientId__c +
                    '&client_secret=' + credentials.ClientSecret__c +
                    '&username=' + credentials.userName__c +
                    '&password=' + credentials.password__c;
            request.setBody(body);
            HttpResponse response = http.send(request);
            ResponseWrapper responseWrapper = (ResponseWrapper) JSON.deserialize(response.getBody(), ResponseWrapper.class);
            Cache.Org.getPartition('local.myCache').put('token', responseWrapper.access_token);
            Cache.Org.getPartition('local.myCache').put('tokenExpires', Datetime.now().addHours(1).format());
        } catch (Exception e) {
            e.getMessage();
        }
    }

    public static List<Log__c> makeInsertCallout(Set<ID> footballersIds) {
        List<Footballer__c> newFootballers = getFootballersBySetIds(footballersIds);
        List<FootballerManager.FootballerWrapper> newFootballerWrappers =
                footballersToFootballerWrappers(newFootballers);
        String message;
        Http http = new Http();
        List<FootballerManager.Result> insertResults = new List<FootballerManager.Result>();
        HttpRequest request = createHttpRequest(newFootballerWrappers, 'POST');
        try {
            HttpResponse response = http.send(request);
            insertResults = (List<FootballerManager.Result>) JSON.deserialize(response.getBody(), List<FootballerManager.Result>.class);
            setExternalID(insertResults);
        } catch (Exception e) {
            insertResults = createResultsWhenException(newFootballerWrappers, e.getMessage());
        }
        return LogService.createLog(insertResults, request.getMethod(), newFootballers, newFootballerWrappers);
    }

    public static List<Log__c> makeUpdateCallout(Set<ID> footballersIds) {
        List<Footballer__c> newFootballers = getFootballersBySetIds(footballersIds);
        List<FootballerManager.FootballerWrapper> newFootballerWrappers =
                footballersToFootballerWrappers(newFootballers);
        String message;
        Http http = new Http();
        HttpRequest request = createHttpRequest(newFootballerWrappers, 'PUT');
        List<FootballerManager.Result> updateResults = new List<FootballerManager.Result>();
        try {
            HttpResponse response = http.send(request);
            updateResults = (List<FootballerManager.Result>) JSON.deserialize(response.getBody(), List<FootballerManager.Result>.class);
            setExternalID(updateResults);
        } catch (Exception e) {
            updateResults = createResultsWhenException(newFootballerWrappers, e.getMessage());
        }
        return LogService.createLog(updateResults, request.getMethod(), newFootballers, newFootballerWrappers);
    }

    public static List<Log__c> makeDeleteCallout(List<FootballerManager.FootballerWrapper> footballerWrappers) {
        String message;
        Http http = new Http();
        List<FootballerManager.FootballerWrapper> newFootballerWrappers =
                footballersWrappersToDeleteRequest(footballerWrappers);
        HttpRequest request = createHttpRequest(newFootballerWrappers, 'DELETE');
        List<FootballerManager.Result> deleteResults = new List<FootballerManager.Result>();
        try {
            HttpResponse response = http.send(request);
            deleteResults = (List<FootballerManager.Result>) JSON.deserialize(response.getBody(), List<FootballerManager.Result>.class);
            clearAfterDeleteSyncSuccess(deleteResults);
        } catch (Exception e) {
            deleteResults = createResultsWhenException(newFootballerWrappers, e.getMessage());
        }
        return LogService.createLog(deleteResults, request.getMethod(), null, newFootballerWrappers);
    }

    private static List<Footballer__c> getFootballersBySetIds(Set<ID> footballersIds) {
        return [
                SELECT Id, ExternalId__c, Name, FirstName__c, Birthday__c, Age__c, Country__c, Synchronized__c, Team__c,SynchroAttempt__c
                FROM Footballer__c
                WHERE Id IN :footballersIds
        ];
    }

    private static List<FootballerManager.FootballerWrapper> footballersToFootballerWrappers(
            List<Footballer__c> footballers) {
        List<FootballerManager.FootballerWrapper> footballerWrappers = new List<FootballerManager.FootballerWrapper>();
        for (Footballer__c footballer : footballers) {
            FootballerManager.FootballerWrapper footballerWrapper = FootballerManager.footballerToWrapper(footballer);
            footballerWrapper.externalId = footballer.Id;
            footballerWrappers.add(footballerWrapper);
        }
        return footballerWrappers;
    }

    private static List<FootballerManager.FootballerWrapper> footballersWrappersToDeleteRequest(
            List<FootballerManager.FootballerWrapper> footballerWrappers) {
        List<FootballerToSync__c> footballersToSync = [
                SELECT ExternalId__c,IdSyncObject__c,SynchroAttempt__c
                FROM FootballerToSync__c
        ];
        for (FootballerToSync__c footballerToSync : footballersToSync) {
            FootballerManager.FootballerWrapper footballerWrapper = new FootballerManager.FootballerWrapper();
            footballerWrapper.externalId = footballerToSync.ExternalId__c;
            footballerWrapper.id = footballerToSync.ExternalId__c;
            footballerWrapper.synchronizationCounter = (Integer) footballerToSync.SynchroAttempt__c;
            footballerWrappers.add(footballerWrapper);
        }
        return footballerWrappers;
    }

    private static List<FootballerManager.Result> createResultsWhenException(
            List <FootballerManager.FootballerWrapper> footballerWrappers,
            String message) {
        List<FootballerManager.Result> results = new List<FootballerManager.Result>();
        for (Integer i = 0; i < footballerWrappers.size(); i++) {
            FootballerManager.Result result =
                    new FootballerManager.Result(false,
                            footballerWrappers.get(i),
                            message, Date.today().format(),
                            UserInfo.getName());
            results.add(result);
        }
        return results;
    }

    private static HttpRequest createHttpRequest(
            List<FootballerManager.FootballerWrapper> newFootballerWrappers,
            String method) {
        isConnectNeeded();
        String newFootballerWrappersJSON = '{"footballerWrappers":' + JSON.serialize(newFootballerWrappers) + '}';
        HttpRequest request = new HttpRequest();
        request.setEndpoint(REST_ENDPOINT);
        request.setMethod(method);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + (String) Cache.Org.getPartition('local.myCache').get('token'));
        String body = newFootballerWrappersJSON;
        request.setBody(body);
        return request;
    }

    private static void setExternalID(List<FootballerManager.Result> results) {
        List<ID> ids = new List<ID>();
        List<String> externalIds = new List<String>();
        if (results != null) {
            for (FootballerManager.Result result : results) {
                if (result.success != null && result.success) {
                    ids.add(result.footballerWrapper.id);
                    externalIds.add(result.footballerWrapper.externalId);
                }
            }
            List<Footballer__c> footballers = [
                    SELECT Id,ExternalId__c,Name,FirstName__c,Birthday__c,Age__c,Country__c,Synchronized__c,Team__c,SynchroAttempt__c
                    FROM Footballer__c
                    WHERE Id IN :ids
            ];
            for (Integer i = 0; i < footballers.size(); i++) {
                footballers.get(i).ExternalId__c = externalIds.get(i);
                footballers.get(i).Synchronized__c = true;
                footballers.get(i).SynchroAttempt__c = 0;
            }
            TriggerSwitcher__c triggerSwitcher = TriggerSwitcher__c.getValues('FootballersTrigger');
            triggerSwitcher.run__c = false;
            update triggerSwitcher;
            update footballers;
            triggerSwitcher.run__c = true;
            update triggerSwitcher;
        }
    }

    public static void clearAfterDeleteSyncSuccess(List<FootballerManager.Result> results) {
        List<ID> ids = new List<ID>();
        List<String> externalIds = new List<String>();
        if (results != null) {
            for (FootballerManager.Result result : results) {
                if (result.success != null && result.success) {
                    ids.add(result.footballerWrapper.id);
                    externalIds.add(result.footballerWrapper.externalId);
                }
            }
        }
        delete [
                SELECT Id
                FROM FootballerToSync__c
                WHERE ExternalId__c IN :externalIds
        ];
    }

    private static void isConnectNeeded() {
        if (Cache.Org.getPartition('local.myCache').get('tokenExpires') == null
                || DateTime.parse((String) Cache.Org.getPartition('local.myCache').get('tokenExpires')) < Datetime.now()) {
            makeConnectCallout();
        }
    }

    public class ResponseWrapper {
        String access_token;
        String instance_url;
    }
}