import ballerina/http;
import ballerina/time;
import ballerina/sql;
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;
import ballerina/io;


// Default HTTP listener for the service
listener http:Listener httpDefaultListener = http:getDefaultListener();

// PostgreSQL connection options
postgresql:Options postgresqlOptions = {
    connectTimeout: 10 // Set connection timeout to 10 seconds
};

// Define a record type to represent the produce table
type Produce record {|
    readonly string id; 
    string name;
|};

// Define a record type for the database configuration
type DB record {|
    string dbHost;
    int dbPort;
    string dbUser;
    string dbPass;
    string dbName;
|};

// Load the database configuration from a Ballerina configuration file
configurable DB db = ?;


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

        // Return the health check response
        return {
            "status": "OK",
            "message": "Farm2Market API service is running",
            "timestamp": currentTimeString
        };
    }
}

// Function to connect to the PostgreSQL database
public function connectDb() returns postgresql:Client|error {
    
        // Create a new PostgreSQL client using the configuration parameters
        // The db variable is expected to be defined in the Config.toml file
        postgresql:Client dbClient =  check new (
        host = db.dbHost,
        port = db.dbPort,
        username = db.dbUser,
        password = db.dbPass,
        database = db.dbName,
        options = postgresqlOptions
        );

        // Return the database client
        return dbClient;       
}

// Function to get the PostgreSQL client or throw an error if connection fails
public function getDbClientOrThrow() returns postgresql:Client {

    // Log the attempt to connect to the database
    io:println("Attempting DB connection...");

    // Try to connect to DB
    postgresql:Client|error clientResult = connectDb();

    // If the connection fai`ls, panic with an error message
    if clientResult is error {

        // Panic with a generic error message
        panic error("DB connection failed!");

        // Panic with the error message from the connection attempt
        // panic error("DB connection failed!: " + clientResult.message());
    }
    // If the connection is successful, log success and return the client
    io:println("DB connection successful.\n");

    // Return the connected PostgreSQL client
    return clientResult;
}

// Function to retrieve produce data from the database
public function retrieveProduceData() returns Produce[]|error {

    // Query to select all records from the "produce" table
    sql:ParameterizedQuery query = `SELECT * FROM produce`;

    // Create a new PostgreSQL client connection
    postgresql:Client dbClient = getDbClientOrThrow();

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
