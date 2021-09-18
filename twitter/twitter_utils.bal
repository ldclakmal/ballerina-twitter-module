import ldclakmal/oauth1;

isolated function getSecurityHeaders(oauth1:ClientOAuthHandler oauthHandler, string httpMethod, string requestPath) 
                                    returns map<string|string[]>|Error {
    map<string|string[]>|error headers = oauthHandler.getSecurityHeaders(httpMethod, TWITTER_API_URL + requestPath);
    if headers is error {
        return prepareError("Error occurred while generating authorization header.", headers);
    } else {
        return headers;
    }
}

isolated function prepareErrorResponse(json response) returns Error {
    json|error errors = response.errors;
    if (errors is json[]) {
        return prepareError(errors[0].toString());
    } else if (errors is json) {
        return prepareError(errors.toString());
    } else {
        return prepareError("Error occurred while accessing the JSON payload of the error response.");
    }
}
