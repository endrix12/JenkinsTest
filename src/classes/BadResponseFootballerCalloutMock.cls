@isTest
global class BadResponseFootballerCalloutMock implements HttpCalloutMock {
    String endpoint = 'https://britenetspkazoo-dev-ed.my.salesforce.com/services/apexrest/Footballer';

    global HTTPResponse respond(HTTPRequest request) {

        FootballerManager.Request requestBody = (FootballerManager.Request) JSON.deserialize(request.getBody(), FootballerManager.Request.class);
        List <FootballerManager.FootballerWrapper> footballerWrappers = requestBody.footballerWrappers;
        List <FootballerManager.Result> results =new List<FootballerManager.Result>();
        List<String> messages = new List<String>();
        for (FootballerManager.Result result: results) {
            result.message='Error';
            result.success=false;
            result.resultDate=Date.today().format();
            result.user=UserInfo.getName();
            results.add(result);
        }
        String responseBody = JSON.serialize(results);
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(responseBody);
        response.setStatusCode(400);
        return response;
    }
}