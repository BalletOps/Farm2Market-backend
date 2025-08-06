import ballerina/sql;
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;
import Farm2Market_backend.types;
import Farm2Market_backend.utils;

// Get produce data from the database
public function getProduceData() returns types:Produce[]|error {

    // Query to select all records from the "produce" table
    sql:ParameterizedQuery query = `SELECT * FROM produce`;

    // Create a new PostgreSQL client connection
    postgresql:Client dbClient = utils:getDbClientOrThrow();

    // Execute the query and get a stream of results
    stream<types:Produce, sql:Error?> resultStream = dbClient->query(query);

    // Collect results into an array
    types:Produce[] produceList = [];
    check from types:Produce produce in resultStream
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