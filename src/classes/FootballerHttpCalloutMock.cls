@isTest
global class FootballerHttpCalloutMock implements HttpCalloutMock {
  private  String endpoint = 'callout:FootballerCallout';

    global HTTPResponse respond(HTTPRequest request) {

        FootballerManager.Request requestBody = (FootballerManager.Request) JSON.deserialize(request.getBody(), FootballerManager.Request.class);
        List <FootballerManager.FootballerWrapper> footballerWrappers = requestBody.footballerWrappers;
        List <FootballerManager.Result> results =new List<FootballerManager.Result>();
        for (FootballerManager.FootballerWrapper footballerWrapper: footballerWrappers) {
            FootballerManager.Result result = new FootballerManager.Result();
            result.message='Success';
            result.success=true;
            result.resultDate=Date.today().format();
            result.user=UserInfo.getName();
            result.footballerWrapper = footballerWrapper;
            results.add(result);
        }
        String responseBody = JSON.serialize(results);
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(responseBody);
        response.setStatusCode(200);
        return response;
    }
}