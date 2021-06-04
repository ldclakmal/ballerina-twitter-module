// Convert the response json to `Status` record.
isolated function convertToStatus(map<json> response) returns Status {
    Status status = {
        createdAt: response["created_at"].toString(),
        id: <int>response["id"],
        text: response["text"].toString(),
        'source: response["'source"].toString(),
        truncated: <boolean>response["truncated"],
        favorited: <boolean>response["favorited"],
        retweeted: <boolean>response["retweeted"],
        favoriteCount: <int>response["favorite_count"],
        retweetCount: <int>response["retweet_count"],
        lang: response["lang"].toString()
    };
    return status;
}

// Convert the array of json response into `Status` record array.
isolated function convertToStatuses(json[] response) returns Status[] {
    Status[] statuses = [];
    int i = 0;
    foreach json status in response {
        statuses[i] = convertToStatus(<map<json>>status);
        i = i + 1;
    }
    return statuses;
}
