import ballerina/http;
import ballerina/time;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /api on httpDefaultListener {

    // Health check endpoint to verify if the service is running
    resource function get health() returns json {

        // Get the current UTC time and format it as a string
        time:Utc currentUtc = time:utcNow();
        string currentTimeString = time:utcToString(currentUtc);

        return {
            "status": "OK",
            "message": "Farm2Market API service is running",
            "timestamp": currentTimeString
        };
    }
}