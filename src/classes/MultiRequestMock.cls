global class MultiRequestMock implements HttpCalloutMock {

    private Map<String, HttpCalloutMock> requests;

    global MultiRequestMock(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }

    global HttpResponse respond(HttpRequest request) {
        HttpCalloutMock mock = requests.get(request.getEndpoint());
        if(mock != null) {
            return mock.respond(request);
        } else {
            return null;
        }
    }
}