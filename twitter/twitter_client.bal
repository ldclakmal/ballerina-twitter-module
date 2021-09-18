import ballerina/http;
import ballerina/url;
import ldclakmal/oauth1;

# The Twitter client configurations.
#
# + accessToken - The access token of the Twitter account
# + accessTokenSecret - The access token secret of the Twitter account
# + consumerKey - The consumer key of the Twitter account
# + consumerSecret - The consumer secret of the Twitter account
# + clientConfig - HTTP client configurations
public type Configuration record {
    string accessToken;
    string accessTokenSecret;
    string consumerKey;
    string consumerSecret;
    http:ClientConfiguration clientConfig = {};
};

# The Twitter client object.
public isolated client class Client {

    private final http:Client twitterClient;
    private final oauth1:ClientOAuthHandler oauthHandler;

    public isolated function init(Configuration twitterConfig) returns Error? {
        http:Client|http:ClientError result = new(TWITTER_API_URL, twitterConfig.clientConfig);
        if (result is http:Client) {
            self.twitterClient = result;
        } else {
            return prepareError("Failed to init Twitter client.", result);
        }
        self.oauthHandler = new({
            consumerKey: twitterConfig.consumerKey,
            consumerSecret: twitterConfig.consumerSecret,
            accessToken: twitterConfig.accessToken,
            accessTokenSecret: twitterConfig.accessTokenSecret
        });
    }

    # Updates the authenticating user's current status, also known as Tweeting.
    #
    # + status - The text of status update
    # + return - If success, returns `twitter:Status` object, else returns `twitter:Error`
    isolated remote function tweet(string status) returns @tainted Status|Error {
        string|url:Error encodedStatus = url:encode(status, UTF_8);
        if (encodedStatus is url:Error) {
            return prepareError("Error occurred while encoding the status.");
        }
        string requestPath = UPDATE_API + "?" + "status=" + checkpanic encodedStatus;
        map<string|string[]> headers = check getSecurityHeaders(self.oauthHandler, POST, requestPath);
        http:Response|http:ClientError httpResponse = self.twitterClient->post(requestPath, (), headers);
        if (httpResponse is http:Response) {
            json|http:ClientError jsonPayload = httpResponse.getJsonPayload();
            if (jsonPayload is json) {
                int statusCode = httpResponse.statusCode;
                if (statusCode == http:STATUS_OK) {
                    return convertToStatus(<map<json>>jsonPayload);
                } else {
                    return prepareErrorResponse(jsonPayload);
                }
            } else {
                return prepareError("Error occurred while accessing the JSON payload of the response.");
            }
        } else {
            return prepareError("Error occurred while invoking the REST API.");
        }
    }

    # Retweets a tweet, specified by the id parameter. Returns the original Tweet with Retweet details embedded.
    #
    # + id - The numerical ID of the desired status
    # + return - If success, returns `twitter:Status` object, else returns `twitter:Error`
    isolated remote function retweet(int id) returns @tainted Status|Error {
        string requestPath = RETWEET_API + id.toString() + ".json";
        map<string|string[]> headers = check getSecurityHeaders(self.oauthHandler, POST, requestPath);
        http:Response|http:ClientError httpResponse = self.twitterClient->post(requestPath, (), headers);
        if (httpResponse is http:Response) {
            json|http:ClientError jsonPayload = httpResponse.getJsonPayload();
            if (jsonPayload is json) {
                int statusCode = httpResponse.statusCode;
                if (statusCode == http:STATUS_OK) {
                    return convertToStatus(<map<json>>jsonPayload);
                } else {
                    return prepareErrorResponse(jsonPayload);
                }
            } else {
                return prepareError("Error occurred while accessing the JSON payload of the response.");
            }
        } else {
            return prepareError("Error occurred while invoking the REST API.");
        }
    }

    # Untweets a retweeted status, specified by the id parameter.
    # Returns the original Tweet, with Retweet details embedded.
    #
    # + id - The numerical ID of the desired status
    # + return - If success, returns `twitter:Status` object, else returns `twitter:Error`
    isolated remote function unretweet(int id) returns @tainted Status|Error {
        string requestPath = UN_RETWEET_API + id.toString() + ".json";
        map<string|string[]> headers = check getSecurityHeaders(self.oauthHandler, POST, requestPath);
        http:Response|http:ClientError httpResponse = self.twitterClient->post(requestPath, (), headers);
        if (httpResponse is http:Response) {
            json|http:ClientError jsonPayload = httpResponse.getJsonPayload();
            if (jsonPayload is json) {
                int statusCode = httpResponse.statusCode;
                if (statusCode == http:STATUS_OK) {
                    return convertToStatus(<map<json>>jsonPayload);
                } else {
                    return prepareErrorResponse(jsonPayload);
                }
            } else {
                return prepareError("Error occurred while accessing the JSON payload of the response.");
            }
        } else {
            return prepareError("Error occurred while invoking the REST API.");
        }
    }

    # Returns a collection of relevant Tweets matching a specified query.
    #
    # + query - Query string of 500 characters maximum, including operators
    # + advancedSearch - Optional params that is needed for advanced search operations
    # + return - If success, `twitter:Status[]` object, else returns `error`
    remote function search(string query, AdvancedSearch? advancedSearch = ()) returns @tainted Status[]|Error {
        string|url:Error encodedQuery = url:encode(query, UTF_8);
        if (encodedQuery is error) {
            return prepareError("Error occurred while encoding the query.");
        }
        string requestPath = SEARCH_API + "?" + "q=" + checkpanic encodedQuery;
        map<string|string[]> headers = check getSecurityHeaders(self.oauthHandler, GET, requestPath);
        http:Response|http:ClientError httpResponse = self.twitterClient->get(requestPath, headers);
        if (httpResponse is http:Response) {
            json|http:ClientError jsonPayload = httpResponse.getJsonPayload();
            if (jsonPayload is json) {
                int statusCode = httpResponse.statusCode;
                if (statusCode == http:STATUS_OK) {
                    return convertToStatuses(<json[]>(checkpanic jsonPayload.statuses));
                } else {
                    return prepareErrorResponse(jsonPayload);
                }
            } else {
                return prepareError("Error occurred while accessing the JSON payload of the response.");
            }
        } else {
            return prepareError("Error occurred while invoking the REST API.");
        }

    }

    # Returns a single Tweet, specified by the id parameter. The Tweet's author will also be embedded within the Tweet.
    #
    # + id - The numerical ID of the desired status
    # + return - If success, returns `twitter:Status` object, else returns `twitter:Error`
    isolated remote function getTweet(int id) returns @tainted Status|Error {
        string requestPath = SHOW_STATUS_API + "?" + "id=" + id.toString();
        map<string|string[]> headers = check getSecurityHeaders(self.oauthHandler, GET, requestPath);
        http:Response|http:ClientError httpResponse = self.twitterClient->get(requestPath, headers);
        if (httpResponse is http:Response) {
            json|http:ClientError jsonPayload = httpResponse.getJsonPayload();
            if (jsonPayload is json) {
                int statusCode = httpResponse.statusCode;
                if (statusCode == http:STATUS_OK) {
                    return convertToStatus(<map<json>>jsonPayload);
                } else {
                    return prepareErrorResponse(jsonPayload);
                }
            } else {
                return prepareError("Error occurred while accessing the JSON payload of the response.");
            }
        } else {
            return prepareError("Error occurred while invoking the REST API.");
        }
    }

    # Destroys the status. The authenticating user must be the author of the specified status.
    # Returns the destroyed status; if successful.
    #
    # + id - The numerical ID of the desired status
    # + return - If success, returns `twitter:Status` object, else returns `twitter:Error`
    isolated remote function deleteTweet(int id) returns @tainted Status|Error {
        string requestPath = DESTROY_STATUS_API + id.toString() + ".json";
        map<string|string[]> headers = check getSecurityHeaders(self.oauthHandler, POST, requestPath);
        http:Response|http:ClientError httpResponse = self.twitterClient->post(requestPath, (), headers);
        if (httpResponse is http:Response) {
            json|http:ClientError jsonPayload = httpResponse.getJsonPayload();
            if (jsonPayload is json) {
                int statusCode = httpResponse.statusCode;
                if (statusCode == http:STATUS_OK) {
                    return convertToStatus(<map<json>>jsonPayload);
                } else {
                    return prepareErrorResponse(jsonPayload);
                }
            } else {
                return prepareError("Error occurred while accessing the JSON payload of the response.");
            }
        } else {
            return prepareError("Error occurred while invoking the REST API.");
        }
    }
}
