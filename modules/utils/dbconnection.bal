import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;

// PostgreSQL connection options
postgresql:Options postgresqlOptions = {
    connectTimeout: 10 // Set connection timeout to 10 seconds
};

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

    // // Log the attempt to connect to the database
    // logWithTime({
    //     message: "Attempting DB connection...",
    //     level: "INFO",
    //     location: "utils/dbconnection:getDbClientOrThrow",
    //     context: "DbConnection"
    // });
    
    // Try to connect to DB
    postgresql:Client|error clientResult = connectDb();

    // If the connection fai`ls, panic with an error message
    if clientResult is error {

        
        logWithTime({
            message: "DB connection failed!",
            level: "ERROR",
            location: "utils/dbconnection:getDbClientOrThrow",
            context: "DbConnection"
        });

        // Panic with error message
        panic error(clientResult.message());
    }

    // Log successful connection to the database
    logWithTime({
            message: "Connected to DB.",
            level: "INFO",
            location: "utils/dbconnection:getDbClientOrThrow",
            context: "DbConnection"
        });

    // Return the connected PostgreSQL client
    return clientResult;
}
