import ballerina/io;
import ballerina/time;

// Define a record for common log parameters
public type LogParams record {
    string message = "No message provided.";
    string level = "LOG";
    string location = "";
    string context = "";
};

// Logs a message with optional details.
public function log(
    LogParams params = {},
    io:Printable... extraMessages
) {
    logInternal(params, false, ...extraMessages);
}

// Logs a message with optional details and current time.
public function logWithTime(
    LogParams params = {},
    io:Printable... extraMessages
) {
    logInternal(params, true, ...extraMessages);
}

// Internal function to handle logging with or without time.
function logInternal(
    LogParams params,
    boolean includeTime,
    io:Printable... extraMessages
) {
    string logLine = "[" + params.level + "]";

    if params.location != "" {
        logLine += " [" + params.location + "]";
    }

    if params.context != "" {
        logLine += " [" + params.context + "]";
    }

    if includeTime {
        time:Utc currentUtc = time:utcNow();
        string currentTimeString = time:utcToString(currentUtc);
        logLine += " [" + currentTimeString + "]";
    }

    logLine += ":\n---- " + params.message;

    io:println(logLine);

    foreach var msg in extraMessages {
        io:println("---- ", msg);
    }

    io:println();
}
