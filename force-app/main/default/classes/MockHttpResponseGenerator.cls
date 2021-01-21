global class MockHttpResponseGenerator implements HttpCalloutMock {
    protected Integer code;
    protected String status;
    protected String bodyAsString;
    protected Blob bodyAsBlob;
    protected Map<String, String> responseHeaders;
    protected String endpoint;
    protected String reqMethod;

    public final static String POST_METHOD = 'POST';
    public final static String PATCH_METHOD = 'PATCH';
    public final static String DELETE_METHOD = 'DELETE';

    public MockHttpResponseGenerator(Integer code, String status, String body, Map<String, String> responseHeaders, String endpoint, String reqMethod) {
        this.code = code;
        this.status = status;
        this.bodyAsString = body;
        this.responseHeaders = responseHeaders;
        this.endpoint = endpoint;
        this.reqMethod = reqMethod;
    }

    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatus(status); // OK
        response.setStatusCode(code); // 200
        if(bodyAsBlob != null) {
            response.setBodyAsBlob(bodyAsBlob); 
        } else {
            response.setBody(bodyAsString); //'{ "success": true, "message":"Insert user successfully!", "code":200 }'
        }

        if(responseHeaders != null) {
            for(String key: responseHeaders.keySet()) {
                response.setHeader(key, responseHeaders.get(key));
            }
        }

        System.assertEquals(endpoint, request.getEndpoint());
        System.assertEquals(reqMethod, request.getMethod());

        return response;
    }
}
