# Ballerina Twitter Connector

`Ballerina Twitter Connector` is a library that is used to connects to Twitter from <a target="_blank" href="https://ballerina.io/">Ballerina</a>.

Twitter is what’s happening now. Twitter’s developer platform provides many API products, tools, and resources that enable you to harness the power of Twitter's open, global, and real-time communication network.

The Ballerina Twitter connector allows you to tweet, retweet, un-retweet, search, retrieve and delete status (AKA Tweets) through the Twitter REST API.

**Status Operations**

The `ldclakmal/twitter` module contains operations that work with statuses. Status is also known as a 'Tweet'. You can update the current status, retweet a tweet, un-tweet a retweeted status, retrieve a status, and delete a status.

**Search Operations**

The `ldclakmal/twitter` module contains operations that search for statuses. Status is also known as a 'Tweet'.

## Compatibility
|                    | Version                                                          |
|:------------------:|:----------------------------------------------------------------:|
| Ballerina Language | Swan Lake Beta 2 (or later)                                      |
| Twitter API        | [1.1](https://developer.twitter.com/en/docs/api-reference-index) |

## Getting Started

The Ballerina Twitter connector can be instantiated using the Consumer Key (API Key), Consumer Secret (API Secret Key), Access Token, and Access Token Secret in the Twitter configuration.

### Obtaining API Keys and Tokens

1. Create a **Twitter Account**, if you don't have and sign in.
2. Visit [**Twitter Developer Platform**](https://apps.twitter.com/app/new).
3. Apply for a **Twitter Developer Account**, if you don't have. Refer to [Developer Portal Guide](https://developer.twitter.com/en/docs/developer-portal/overview).
3. Once the **Twitter Developer Account** created, sign in and create a **Project** and an **App**.
4. Generate **Consumer Keys** and **Authentication Tokens** at **Keys and tokens** tab of the **App** you created.
5. Copy the **Consumer Key** (API Key), **Consumer Secret** (API Secret Key), **Access Token**, and **Access Token Secret** from the screen.

> **NOTE:** For more information, refer to the [Getting started](https://developer.twitter.com/en/docs/getting-started) guide.

### Configuring the Connector

You can now enter the credentials obtained in the `Config.toml` file as follows:
```bash
CONSUMER_KEY="<Your Consumer Key>"
CONSUMER_SECRET="<Your Consumer Secret>"
ACCESS_TOKEN="<Your Access Token>"
ACCESS_TOKEN_SECRET="<Your Access Token Secret>"
```

Or you can set the values as environmental variables with the same keys as follows:
```bash
export CONSUMER_KEY="<Your Consumer Key>"
export CONSUMER_SECRET="<Your Consumer Secret>"
export ACCESS_TOKEN="<Your Access Token>"
export ACCESS_TOKEN_SECRET="<Your Access Token Secret>"
```

Then, import the `ldclakmal/twitter` module into the Ballerina project.

```ballerina
import ldclakmal/twitter;
```

Now, create the Twitter client using the credentials entered into `Config.toml` file or environmental variables. (Here, we read the credentials from the `Config.toml` and the default value is set to the values read from the environmental variables.)

```ballerina
configurable string & readonly CONSUMER_KEY = os:getEnv("CONSUMER_KEY");
configurable string & readonly CONSUMER_SECRET = os:getEnv("CONSUMER_SECRET");
configurable string & readonly ACCESS_TOKEN = os:getEnv("ACCESS_TOKEN");
configurable string & readonly ACCESS_TOKEN_SECRET = os:getEnv("ACCESS_TOKEN_SECRET");

twitter:Configuration twitterConfig = {
    consumerKey: CONSUMER_KEY,
    consumerSecret: CONSUMER_SECRET,
    accessToken: ACCESS_TOKEN,
    accessTokenSecret: ACCESS_TOKEN_SECRET
};
twitter:Client twitterClient = check new(twitterConfig);
```

> **NOTE:** For more information, refer to the [Configurability](https://ballerina.io/learn/user-guide/configurability/defining-configurable-variables/) guides.

### API Guide

#### Tweet a message

The `tweet` API updates the current status as a Tweet. If the status was updated successfully, the response from the `tweet` API is a `twitter:Status` object with the ID of the status, created time of status, etc. If the status update was unsuccessful, the response is a `error`.

```ballerina
string status = "This is a sample tweet!";
twitter:Status|twitter:Error result = twitterClient->tweet(status);
if (result is twitter:Status) {
    // If successful, print the tweet ID and text.
    io:println("Tweet ID: ", result.id);
    io:println("Tweet: ", result.text);
} else {
    // If unsuccessful, print the error returned.
    log:printError("Failed to tweet.", 'error = result);
}
```

#### Retweet a message

The `retweet` API retweets a Tweet. It returns a `twitter:Status` object if successful or an `error` if unsuccessful.

```ballerina
int tweetId = 1401078581493747717;
twitter:Status|twitter:Error result = twitterClient->retweet(tweetId);
if (result is twitter:Status) {
    io:println("Retweet ID: ", result.id);
} else {
    log:printError("Failed to retweet.", 'error = result);
}
```

#### Undo a retweeted message

The `unretweet` API undo retweet of a Tweet. It returns a `twitter:Status` object if successful or an `error` if unsuccessful.

```ballerina
int tweetId = 1401078581493747717;
twitter:Status|twitter:Error result = twitterClient->unretweet(tweetId);
if (result is twitter:Status) {
    io:println("Unretweet ID: ", result.id);
} else {
    log:printError("Failed to unretweet.", 'error = result);
}
```

#### Get a tweet message

The `getTweet` API returns a single Tweet, specified by the id parameter. It returns a `twitter:Status` object if successful or an `error` if unsuccessful.

```ballerina
int tweetId = 1401079510183944195;
twitter:Status|twitter:Error result = twitterClient->getTweet(tweetId);
if (result is twitter:Status) {
    io:println("Get Tweet ID: ", result.id);
} else {
    log:printError("Failed to get a tweet.", 'error = result);
}
```

#### Delete a tweet message

The `deleteTweet` API destroys the Tweet, specified by the id parameter. It returns a `twitter:Status` object if successful or an `error` if unsuccessful.

```ballerina
int tweetId = 1401078581493747717;
twitter:Status|twitter:Error result = twitterClient->deleteTweet(tweetId);
if (result is twitter:Status) {
    io:println("Delete Tweet: ", result.id);
} else {
    log:printError("Failed to delete a tweet.", 'error = result);
}
```

#### Search for tweet message(s)

The `search` API searches for Tweets using a query string. It returns a `twitter:Status[]` object if successful or an `error` if unsuccessful.

```ballerina
string query = "twitter";
twitter:Status[]|twitter:Error result = twitterClient->search(query);
if (result is twitter:Status[]) {
    io:println("Search Result: ", result);
} else {
    log:printError("Failed to search a query.", 'error = result);
}
```

## Examples

```ballerina
import ballerina/io;
import ballerina/log;
import ballerina/os;
import ldclakmal/twitter;

configurable string & readonly CONSUMER_KEY = os:getEnv("CONSUMER_KEY");
configurable string & readonly CONSUMER_SECRET = os:getEnv("CONSUMER_SECRET");
configurable string & readonly ACCESS_TOKEN = os:getEnv("ACCESS_TOKEN");
configurable string & readonly ACCESS_TOKEN_SECRET = os:getEnv("ACCESS_TOKEN_SECRET");

twitter:Configuration twitterConfig = {
    consumerKey: CONSUMER_KEY,
    consumerSecret: CONSUMER_SECRET,
    accessToken: ACCESS_TOKEN,
    accessTokenSecret: ACCESS_TOKEN_SECRET
};
twitter:Client twitterClient = check new(twitterConfig);

public function main() {
    string status = "This is a sample tweet!";
    twitter:Status|twitter:Error result = twitterClient->tweet(status);
    if (result is twitter:Status) {
        // If successful, print the tweet ID and text.
        io:println("Tweet ID: ", result.id);
        io:println("Tweet: ", result.text);
    } else {
        // If unsuccessful, print the error returned.
        log:printError("Failed to tweet.", 'error = result);
    }
}
```
