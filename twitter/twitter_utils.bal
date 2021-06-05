import ballerina/crypto;
import ballerina/time;
import ballerina/url;
import ballerina/uuid;

isolated function generateAuthorizationHeader(Credential twitterCredential, string httpMethod, string serviceEP,
                                              string? urlParams = ()) returns string|Error {
    string nonce = uuid:createType4AsString();
    int timeInSeconds = time:utcNow()[0];
    string timeStamp = timeInSeconds.toString();

    string requestParams = "oauth_consumer_key=" + twitterCredential.consumerKey + "&oauth_nonce=" + nonce +
                            "&oauth_signature_method=HMAC-SHA1&oauth_timestamp=" + timeStamp + "&oauth_token=" +
                            twitterCredential.accessToken + "&oauth_version=1.0";

    if (urlParams is string) {
        int comparison = 'string:codePointCompare(requestParams, urlParams);
        if (comparison == -1) {
            requestParams += "&" + urlParams;
        } else {
            requestParams = urlParams + "&" + requestParams;
        }
    }
    string|url:Error encodedRequestParams = url:encode(requestParams, UTF_8);
    string|url:Error encodedServiceEP = url:encode(TWITTER_API_URL + serviceEP, UTF_8);
    string|url:Error encodedConsumerSecret = url:encode(twitterCredential.consumerSecret, UTF_8);
    string|url:Error encodedAccessTokenSecret = url:encode(twitterCredential.accessTokenSecret, UTF_8);
    if (encodedRequestParams is url:Error || encodedServiceEP is url:Error ||
        encodedConsumerSecret is url:Error || encodedAccessTokenSecret is url:Error) {
        return prepareError("Error occurred while generating authorization header.");
    }
    string baseString = httpMethod + "&" + checkpanic encodedServiceEP + "&" + checkpanic encodedRequestParams;
    string key = checkpanic encodedConsumerSecret + "&" + checkpanic encodedAccessTokenSecret;

    byte[]|crypto:Error hmac = crypto:hmacSha1(baseString.toBytes(), key.toBytes());
    if (hmac is crypto:Error) {
        return prepareError("Error occurred while generating authorization header.");
    }
    string signature = (checkpanic hmac).toBase64();

    string|url:Error encodedSignature = url:encode(signature, UTF_8);
    string|url:Error encodedaccessToken = url:encode(twitterCredential.accessToken, UTF_8);
    if (encodedSignature is url:Error || encodedaccessToken is url:Error) {
        return prepareError("Error occurred while generating authorization header.");
    }

    string header = "OAuth oauth_consumer_key=\"" + twitterCredential.consumerKey +
                    "\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"" + timeStamp +
                    "\",oauth_nonce=\"" + nonce + "\",oauth_version=\"1.0\",oauth_signature=\"" +
                    checkpanic encodedSignature + "\",oauth_token=\"" + checkpanic encodedaccessToken + "\"";
    return header;
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
