import ballerina/http;
import ballerina/url;

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

type Credential record {
    string accessToken;
    string accessTokenSecret;
    string consumerKey;
    string consumerSecret;
};

# The Twitter client object.
public isolated client class Client {

    private final http:Client twitterClient;
    private final Credential twitterCredential;

    public isolated function init(Configuration twitterConfig) returns Error? {
        http:Client|http:ClientError result = new(TWITTER_API_URL, twitterConfig.clientConfig);
        if (result is http:Client) {
            self.twitterClient = result;
        } else {
            return prepareError("Failed to init Twitter client.", result);
        }
        self.twitterCredential = {
            accessToken: twitterConfig.accessToken,
            accessTokenSecret: twitterConfig.accessTokenSecret,
            consumerKey: twitterConfig.consumerKey,
            consumerSecret: twitterConfig.consumerSecret
        };
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
        string urlParams = "status=" + checkpanic encodedStatus;

        string header = check generateAuthorizationHeader(self.twitterCredential, POST, UPDATE_API, urlParams);
        http:Request request = new;
        request.setHeader("Authorization", header);
        string requestPath = UPDATE_API + "?" + urlParams;

        http:Response|http:ClientError httpResponse = self.twitterClient->post(requestPath, request);
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
        string header = check generateAuthorizationHeader(self.twitterCredential, POST, requestPath);
        http:Request request = new;
        request.setHeader("Authorization", header);

        http:Response|http:ClientError httpResponse = self.twitterClient->post(requestPath, request);
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
        string header = check generateAuthorizationHeader(self.twitterCredential, POST, requestPath);
        http:Request request = new;
        request.setHeader("Authorization", header);

        http:Response|http:ClientError httpResponse = self.twitterClient->post(requestPath, request);
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
        string urlParams = "q=" + checkpanic encodedQuery;

        string header = check generateAuthorizationHeader(self.twitterCredential, GET, SEARCH_API, urlParams);
        string requestPath = SEARCH_API + "?" + urlParams;

        http:Response|http:ClientError httpResponse = self.twitterClient->get(requestPath, { "Authorization": header });
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
        string urlParams = "id=" + id.toString();

        string header = check generateAuthorizationHeader(self.twitterCredential, GET, SHOW_STATUS_API, urlParams);
        string requestPath = SHOW_STATUS_API + "?" + urlParams;

        http:Response|http:ClientError httpResponse = self.twitterClient->get(requestPath, { "Authorization": header });
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
        string header = check generateAuthorizationHeader(self.twitterCredential, POST, requestPath);
        http:Request request = new;
        request.setHeader("Authorization", header);

        http:Response|http:ClientError httpResponse = self.twitterClient->post(requestPath, request);
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
