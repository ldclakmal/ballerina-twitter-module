[![Build Status](https://travis-ci.com/ldclakmal/ballerina-twitter-module.svg?branch=master)](https://travis-ci.com/ldclakmal/ballerina-twitter-module) [![CI](https://github.com/ldclakmal/ballerina-twitter-module/workflows/CI/badge.svg)](https://github.com/ldclakmal/ballerina-twitter-module/actions?query=workflow%3ACI) [![Deployment](https://github.com/ldclakmal/ballerina-twitter-module/workflows/Deployment/badge.svg)](https://github.com/ldclakmal/ballerina-twitter-module/actions?query=workflow%3ADeployment)

# Ballerina Twitter Connector

Twitter is what’s happening now. Twitter’s developer platform provides many API products, tools, and resources that enable you to harness the power of Twitter's open, global, and real-time communication network. This module provide capabilities to connects to Twitter from Ballerina.

The Twitter connector allows you to tweet, retweet, unretweet, search, retrieve and delete status (AKA Tweets) through the Twitter REST API.

**Status Operations**

The `ldclakmal/twitter` module contains operations that work with statuses. Status is also known as a 'Tweet'. You can update the current status, retweet a tweet, untweet a retweeted status, retrieve a status, and delete a status.

> Twitter API: https://developer.twitter.com/en/docs/tweets/post-and-engage/overview

**Search Operations**

The `ldclakmal/twitter` module contains operations that search for statuses. Status is also known as a 'Tweet'.

> Twitter API: https://developer.twitter.com/en/docs/tweets/search/overview


## Compatibility
|                    | Version                                                          |
|:------------------:|:----------------------------------------------------------------:|
| Ballerina Language | 1.2.0                                                            |
| Twitter API        | [1.1](https://developer.twitter.com/en/docs/api-reference-index) |


## Getting Started

The Twitter connector can be instantiated using the Consumer Key (API key), Consumer Secret (API secret key), Access Token, and Access Token Secret in the Twitter configuration.

**Obtaining API Keys and Tokens to Run the Sample**

1. Create a Twitter account, if you don't have any.
2. Visit https://apps.twitter.com/app/new and sign in.
3. Provide the required information about the application.
4. Agree to the Developer Agreement and click **Create your Twitter application**.
5. After creating your Twitter application, your Consumer Key and Consumer Secret will be displayed in the "Keys and tokens" tab of your app on Twitter.
6. Click the **Keys and tokens** tab, and then enable your Twitter account to use this application by clicking the **Create my access token** button.
7. Copy the Consumer key (API key), Consumer Secret (API secret key), Access Token, and Access Token Secret from the screen.

**NOTE:** For more information, refer to the [Getting started](https://developer.twitter.com/en/docs/basics/getting-started) guide.

You can now enter the credentials in the `ballerina.conf` file as follows:
```bash
CONSUMER_KEY="<Your Consumer Key>"
CONSUMER_SECRET="<Your Consumer Secret>"
ACCESS_TOKEN="<Your Access Token>"
ACCESS_TOKEN_SECRET="<Your Access Token Secret>"
```

## API Guide

First, import the `ldclakmal/twitter` module into the Ballerina project.

```ballerina
import ldclakmal/twitter;
```

Now, create the Twitter client using the credentials entered into `ballerina.conf` file.

```ballerina
twitter:Configuration twitterConfig = {
    consumerKey: config:getAsString("CONSUMER_KEY"),
    consumerSecret: config:getAsString("CONSUMER_SECRET"),
    accessToken: config:getAsString("ACCESS_TOKEN"),
    accessTokenSecret: config:getAsString("ACCESS_TOKEN_SECRET")
};
twitter:Client twitterClient = new(twitterConfig);
```

The `tweet` API updates the current status as a Tweet. If the status was updated successfully, the response from the `tweet` API is a `twitter:Status` object with the ID of the status, created time of status, etc. If the status update was unsuccessful, the response is a `error`.

```ballerina
string status = "This is a sample tweet!";
var result = twitterClient->tweet(status);
if (result is twitter:Status) {
    // If successful, print the tweet ID and text.
    io:println("Tweet ID: ", result.id);
    io:println("Tweet: ", result.text);
} else {
    // If unsuccessful, print the error returned.
    io:println("Error: ", result);
}
```

The `retweet` API retweets a Tweet. It returns a `twitter:Status` object if successful or an `error` if unsuccessful.

```ballerina
int tweetId = 1093833789346861057;
var result = twitterClient->retweet(tweetId);
if (result is twitter:Status) {
    io:println("Retweet ID: ", result.id);
} else {
    io:println("Error: ", result);
}
```

The `unretweet` API undo retweet of a Tweet. It returns a `twitter:Status` object if successful or an `error` if unsuccessful.

```ballerina
int tweetId = 1093833789346861057;
var result = twitterClient->unretweet(tweetId);
if (result is twitter:Status) {
    io:println("Un Retweet ID: ", result.id);
} else {
    io:println("Error: ", result);
}
```

The `getTweet` API returns a single Tweet, specified by the id parameter. It returns a `twitter:Status` object if successful or an `error` if unsuccessful.

```ballerina
int tweetId = 1093833789346861057;
var result = twitterClient->getTweet(tweetId);
if (result is twitter:Status) {
    io:println("Get Tweet ID: ", result.id);
} else {
    io:println("Error: ", result);
}
```

The `deleteTweet` API destroys the Tweet, specified by the id parameter. It returns a `twitter:Status` object if successful or an `error` if unsuccessful.

```ballerina
int tweetId = 1093833789346861057;
var result = twitterClient->deleteTweet(tweetId);
if (result is twitter:Status) {
    io:println("Delete Tweet: ", result.id);
} else {
    io:println("Error: ", result);
}
```

The `search` API searches for Tweets using a query string. It returns a `twitter:Status[]` object if successful or an `error` if unsuccessful.

```ballerina
string query = "twitter";
var result = twitterClient->search(query);
if (result is twitter:Status[]) {
    io:println("Search Result: ", result);
} else {
    io:println("Error: ", result);
}
```

## Examples

```ballerina
import ballerina/io;
import ldclakmal/twitter;

twitter:Configuration twitterConfig = {
    consumerKey: config:getAsString("CONSUMER_KEY"),
    consumerSecret: config:getAsString("CONSUMER_SECRET"),
    accessToken: config:getAsString("ACCESS_TOKEN"),
    accessTokenSecret: config:getAsString("ACCESS_TOKEN_SECRET")
};
twitter:Client twitterClient = new(twitterConfig);

public function main() {
    string status = "This is a sample tweet!";
    var result = twitterClient->tweet(status);
    if (result is twitter:Status) {
        // If successful, print the tweet ID and text.
        io:println("Tweet ID: ", result.id);
        io:println("Tweet: ", result.text);
    } else {
        // If unsuccessful, print the error returned.
        io:println("Error: ", result);
    }
}
```
