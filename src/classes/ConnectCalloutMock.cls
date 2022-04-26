@isTest
global class ConnectCalloutMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest request) {
        String token = '00D7Q000000I1H7!AREAQHbn7KmydlCygJt0FwBa8SVfDRGnnrHS_baWIi1BykDgJPc4NhRG_occyiGGY9DmHEGIxXVWlAVu.Ra4ZqJPjaJPhWOO';
        String responseBody = '{' +
                '"access_token": "' + token + '",' +
                '"instance_url": "https://britenetspkazoo-dev-ed.my.salesforce.com",' +
                '"id": "https://login.salesforce.com/id/00D7Q000000I1H7UAK/0057Q000002bmxyQAA",' +
                '"token_type": "Bearer",' +
                '"issued_at": "1643574884659",' +
                '"signature": "lySkQrPqbdJdPLajWk7EvUT8dMhMFsnXXK9j8OuTelU="' +
                '}';
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(responseBody);
        response.setStatusCode(200);
        return response;
    }
}