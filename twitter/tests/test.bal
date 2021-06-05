import ballerina/os;
import ballerina/test;
import ballerina/time;

int tweetId = -1;

configurable string & readonly CONSUMER_KEY = os:getEnv("CONSUMER_KEY");
configurable string & readonly CONSUMER_SECRET = os:getEnv("CONSUMER_SECRET");
configurable string & readonly ACCESS_TOKEN = os:getEnv("ACCESS_TOKEN");
configurable string & readonly ACCESS_TOKEN_SECRET = os:getEnv("ACCESS_TOKEN_SECRET");

Configuration twitterConfig = {
    consumerKey: CONSUMER_KEY,
    consumerSecret: CONSUMER_SECRET,
    accessToken: ACCESS_TOKEN,
    accessTokenSecret: ACCESS_TOKEN_SECRET
};
Client twitterClient = check new(twitterConfig);

@test:BeforeSuite
function testTweet() {
    time:Utc utcTime = time:utcNow();
    string utcString = time:utcToString(utcTime);
    string status = "Ballerina Twitter Connector: " + utcString;
    Status|Error result = twitterClient->tweet(status);
    if (result is Status) {
        tweetId = <@untainted> result.id;
        test:assertTrue(result.text.includes(status), "Failed to call tweet.");
    } else {
        test:assertFail(result.message());
    }
}

@test:Config {
    after: testUnretweet
}
function testRetweet() {
    Status|Error result = twitterClient->retweet(tweetId);
    if (result is Status) {
        test:assertTrue(result.retweeted, "Failed to call retweet.");
    } else {
        test:assertFail(result.message());
    }
}

@test:Config {}
function testUnretweet() {
    Status|Error result = twitterClient->unretweet(tweetId);
    if (result is Status) {
        test:assertEquals(result.id, tweetId, "Failed to call unretweet.");
    } else {
        test:assertFail(result.message());
    }
}

@test:Config {}
function testGetTweet() {
    Status|Error result = twitterClient->getTweet(tweetId);
    if (result is Status) {
        test:assertEquals(result.id, tweetId, "Failed to call get tweet.");
    } else {
        test:assertFail(result.message());
    }
}

@test:AfterSuite {}
function testDeleteTweet() {
    Status|Error result = twitterClient->deleteTweet(tweetId);
    if (result is Status) {
        test:assertEquals(result.id, tweetId, "Failed to call delete tweet.");
    } else {
        test:assertFail(result.message());
    }
}

@test:Config {}
function testSearch() {
    string query = "#ballerinalang";
    Status[]|Error result = twitterClient->search(query);
    if (result is Status[]) {
        test:assertTrue(result.length() > 0, "Failed to call search.");
    } else {
        test:assertFail(result.message());
    }
}
