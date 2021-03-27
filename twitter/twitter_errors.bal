import ballerina/log;

# Represents the Twitter error.
public type Error distinct error;

// Logs and prepares the `error` as an `twitter:Error`.
isolated function prepareError(string message, error? err = ()) returns Error {
    log:printError(message, 'error = err);
    if (err is error) {
        return error Error(message, err);
    }
    return error Error(message);
}
