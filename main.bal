import ballerina/http;
import ballerina/time;
import ballerina/sql;
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;
import ballerina/io;
import Farm2Market_backend.utils;

// Record the application start time
final time:Utc appStartTime = time:utcNow();

// Default HTTP listener for the service
listener http:Listener httpDefaultListener = http:getDefaultListener();

// Define a record type to represent the produce table
type Produce record {|
    readonly string id; 
    string name;
|};


// Main function
public function main() returns error? {

        // Testing produce data retrieval
        // This is just for demonstration purposes and can be removed in production code
        io:println("Produce Data: ", retrieveProduceData());
}

// Define the HTTP service with the base path /api
service /api on httpDefaultListener {

    // Health check endpoint to verify if the service is running
    resource function get health() returns json {

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
}

// Function to retrieve produce data from the database
public function retrieveProduceData() returns Produce[]|error {

    // Query to select all records from the "produce" table
    sql:ParameterizedQuery query = `SELECT * FROM produce`;

    // Create a new PostgreSQL client connection
    postgresql:Client dbClient = utils:getDbClientOrThrow();

    // Execute the query and get a stream of results
    stream<Produce, sql:Error?> resultStream = dbClient->query(query);

    // Collect results into an array
    Produce[] produceList = [];
    check from Produce produce in resultStream
        do {
            produceList.push(produce);
        };

    // Close the result stream
    check resultStream.close();

    // Close the database client connection
    check dbClient.close();

    // Return an empty array if no records were found
    if produceList.length() == 0 {
        return [];
    }

    // Return the list of produce records
    return produceList;
}
