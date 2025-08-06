import ballerina/http;
import ballerina/time;
import ballerinax/postgresql.driver as _;
import Farm2Market_backend.services;
import Farm2Market_backend.types;
import Farm2Market_backend.utils;

// Record the application start time, which is used for health checks
final time:Utc appStartTime = time:utcNow();

// Default HTTP listener for the service
listener http:Listener httpDefaultListener = http:getDefaultListener();

// Main function
public function main() returns error? {

    // Log the application start event
    utils:log({
        message: "Farm2Market app started.",
        level: "INFO",
        location: "main:main",
        context: "Application"
    });
}


// Define the HTTP service with the base path /api
service /api on httpDefaultListener {

    // Health check endpoint to verify if the service is running [/api/health]
    resource function get health() returns json {
        return services:checkHealth(appStartTime);
    }

    // Endpoint to retrieve produce data [/api/produce]
    resource function get produce() returns types:Produce[]|error {
        return services:getProduceData();
    }
}
