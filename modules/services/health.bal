import ballerina/time;
public function checkHealth(time:Utc appStartTime) returns json {

        // Get the current UTC time and format it as a string
        time:Utc currentUtc = time:utcNow();
        string currentTimeString = time:utcToString(currentUtc);

        // Get uptime duration in seconds
        time:Seconds uptimeSeconds = time:utcDiffSeconds(currentUtc, appStartTime);

        // Return the health check response
        return {
            "service": "Farm2Market API",
            "version": "0.1.0",
            "status": "UP",
            "message": "Service is running",
            "timestamp": currentTimeString,
            "uptime": uptimeSeconds
        };
}