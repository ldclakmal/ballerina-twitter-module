import ballerina/os;
import ballerina/test;
import ballerina/time;

int tweetId = 0;

Configuration twitterConfig = {
    consumerKey: os:getEnv("CONSUMER_KEY"),
    consumerSecret: os:getEnv("CONSUMER_SECRET"),
    accessToken: os:getEnv("ACCESS_TOKEN"),
    accessTokenSecret: os:getEnv("ACCESS_TOKEN_SECRET")
};
Client twitterClient = check new(twitterConfig);

@test:Config {}
function testTweet() {
    time:Utc time = time:utcNow();
    string status = "Ballerina Twitter Connector: " + time[0].toString();
    Status|Error result = twitterClient->tweet(status);
    if (result is Status) {
        tweetId = <@untainted> result.id;
        test:assertTrue(result.text.includes(status), "Failed to call tweet()");
    } else {
        test:assertFail(result.message());
    }
}

@test:Config {}
function testRetweet() {
    Status|Error result = twitterClient->retweet(tweetId);
    if (result is Status) {
        test:assertTrue(result.retweeted, "Failed to call retweet()");
    } else {
        test:assertFail(result.message());
    }
}

@test:Config {}
function testUnretweet() {
    Status|Error result = twitterClient->unretweet(tweetId);
    if (result is Status) {
        test:assertEquals(result.id, tweetId, "Failed to call unretweet()");
    } else {
        test:assertFail(result.message());
    }
}

@test:Config {}
function testGetTweet() {
    Status|Error result = twitterClient->getTweet(tweetId);
    if (result is Status) {
        test:assertEquals(result.id, tweetId, "Failed to call getTweet()");
    } else {
        test:assertFail(result.message());
    }
}

@test:Config {}
function testDeleteTweet() {
    Status|Error result = twitterClient->deleteTweet(tweetId);
    if (result is Status) {
        test:assertEquals(result.id, tweetId, "Failed to call deleteTweet()");
    } else {
        test:assertFail(result.message());
    }
}

@test:Config {}
function testSearch() {
    string query = "#ballerina";
    Status[]|Error result = twitterClient->search(query);
    if (result is Status[]) {
        test:assertTrue(result.length() > 0, "Failed to call search()");
    } else {
        test:assertFail(result.message());
    }
}
